__precompile__()

module JSExpr

using JSON, MacroTools, WebIO
export JSString, @js, @js_str, @var, @new

import WebIO: JSString, JSONContext, JSEvalSerialization

macro js(expr)
    :(JSString(string($(jsstring(expr)...))))
end

# Expressions

jsexpr(x::JSString) = x.s
jsexpr(x::Symbol) = (x==:nothing ? "null" : string(x))
jsexpr(x) = sprint(x) do io, s
    JSON.show_json(io, JSEvalSerialization(), s)
end
jsexpr(x::QuoteNode) = x.value isa Symbol ? jsexpr(string(x.value)) : jsexpr(x.value)
jsexpr(x::LineNumberNode) = nothing

include("util.jl")

function jsexpr_joined(xs, delim=",")
    isempty(xs) && return ""
    F(intersperse(jsexpr.(xs), delim))
end

jsstring(x) = _simplify(_flatten(jsexpr(x)))

function block_expr(args, delim="; ")
    #print(io, "{")
    jsexpr_joined(rmlines(args), delim)
    #print(io, "}")
end

function call_expr(f, args...)
    if f in [:(=), :+, :-, :*, :/, :%, :(==), :(===),
             :(!=), :(!==), :(>), :(<), :(<=), :(>=)]
        return F(["(", jsexpr_joined(args, string(f)), ")"])
    end
    F([jsexpr(f), "(", F([jsexpr_joined(args)]), ")"])
end

function obs_get_expr(x)
    # empty [], special case to get value from an Observable
    F(["WebIO.getval(", jsexpr(x), ")"])
end

function obs_set_expr(x, val)
    # empty [], special case to get value from an Observable
    F(["WebIO.setval(", jsexpr_joined([x, val]), ")"])
end

function jsexpr(o::WebIO.Observable)
    if !haskey(WebIO.observ_id_dict, o)
        error("No scope associated with observer being interpolated")
    end
    _scope, name = WebIO.observ_id_dict[o]
    _scope.value === nothing && error("Scope of the observable doesn't exist anymore.")
    scope = _scope.value

    obsobj = Dict("type" => "observable",
                  "scope" => scope.id,
                  "name" => name,
                  "id" => WebIO.obsid(o))

    jsexpr(obsobj)
end

function ref_expr(x, args...)
    F([jsexpr(x), "[", jsexpr_joined(args), "]"])
end

function func_expr(args, body)
    parts = []
    named = isexpr(args, :call)
    named || push!(parts, "(")
    push!(parts, "function ")
    if named
        push!(parts, string(args.args[1]))
        args.args = args.args[2:end]
    end
    push!(parts, "(")
    isexpr(args, Symbol) ? push!(parts, string(args)) : push!(parts, jsexpr_joined(args.args, ","))
    push!(parts, "){")
    push!(parts, jsexpr(insert_return(body)))
    push!(parts, "}")
    named || push!(parts, ")")
    F(parts)
end

function insert_return(ex)
    if isa(ex, Symbol) || !isexpr(ex, :block)
        Expr(:return, ex)
    else
        isexpr(ex.args[end], :return) && return ex
        ex1 = copy(ex)
        ex1.args[end] = insert_return(ex.args[end])
        ex1
    end
end


function dict_expr(xs)
    parts = []
    xs = map(xs) do x
        if x.head == :(=) || x.head == :kw
            push!(parts, F([jsexpr(x.args[1]), ":", jsexpr(x.args[2])]))
        elseif x.head == :call && x.args[1] == :(=>)
            push!(parts, F([jsexpr(x.args[2]), ":", jsexpr(x.args[3])]))
        else
            error("Invalid pair separator in dict expression")
        end
    end
    F(["{", F(intersperse(parts, ",")), "}"])
end

function vect_expr(xs)
    F(["[", F(intersperse([jsexpr(x) for x in xs], ",")), "]"])
end

function if_block(ex)

    if isexpr(ex, :block)
        if any(x -> isexpr(x, :macrocall) && x.args[1] == Symbol("@var"), ex.args)
            error("@js expression error: @var inside an if statement is not supported")
        end
        F(["(", block_expr(rmlines(ex).args, ", "), ")"])
    else
        jsexpr(ex)
    end
end

function if_expr(xs)
    parts = []
    if length(xs) >= 2    # we have an if
        append!(parts, [jsexpr(xs[1]), " ? ", if_block(xs[2])])
    end

    if length(xs) == 3    # Also have an else
        append!(parts, [" : ", if_block(xs[3])])
    else
        push!(parts, " : undefined")
    end
    F(parts)
end

function for_expr(i, start, to, body, step = 1)
    F(["for(var $i = $start; $i <= $to; $i = $i + $step){",
       block_expr(body), "}"])
end

function jsexpr(x::Expr)
    isexpr(x, :block) && return block_expr(rmlines(x).args)
    x = rmlines(x)
    @match x begin
        d(xs__) => dict_expr(xs)
        Dict(xs__) => dict_expr(xs)
        $(Expr(:comparison, :_, :(==), :_)) => jsexpr_joined([x.args[1], x.args[3]], "==")    # 0.4

        # must include this particular `:call` expr before the catchall below
        $(Expr(:call, :(==), :_, :_)) => jsexpr_joined([x.args[2], x.args[3]], "==")    # 0.5+
        f_(xs__) => call_expr(f, xs...)
        (a_ -> b_) => func_expr(a, b)
        a_.b_ | a_.(b_) => jsexpr_joined([a, b], ".")
        (a_[] = val_) => obs_set_expr(a, val)
        (a_ = b_) => jsexpr_joined([a, b], "=")
        (a_ += b_) => jsexpr_joined([a, b], "+=")
        (a_ && b_) => jsexpr_joined([a, b], "&&")
        (a_ || b_) => jsexpr_joined([a, b], "||")
        $(Expr(:if, :__)) => if_expr(x.args)
        $(Expr(:function, :__)) => func_expr(x.args...)
        a_[] => obs_get_expr(a)
        a_[i__] => ref_expr(a, i...)
        [xs__] => vect_expr(xs)
        (@m_ xs__) => jsexpr(macroexpand(JSExpr, x))
        (for i_ = start_ : to_
            body__
        end) => for_expr(i, start, to, body)
        (for i_ = start_ : step_ : to_
            body__
        end) => for_expr(i, start, to, body, step)
        (return a__) => (F(["return ", !isempty(a) && a[1] !== nothing ? jsexpr(a...) : ""]))
        $(Expr(:quote, :_)) => jsexpr(QuoteNode(x.args[1]))
        $(Expr(:$, :_)) => inter(x.args[1])
        $(Expr(:new, :c_)) => F(["new ", jsexpr(x.args[1])])
        $(Expr(:var, :c_)) => F(["var ", jsexpr(x.args[1])])
        _ => error("JSExpr: Unsupported `$(x.head)` expression, $x")
    end
end

function inter(x)
    if x isa Expr && x.args[1] isa Expr
        x.args[1].head == :...
        return :(join(map(jsexpr, $(esc(x.args[1].args[1]))), ","))
    end
    :(jsexpr($(esc(x)))) # the expr gets kept around till eval
end

macro new(x) Expr(:new, esc(x)) end
macro var(x) Expr(:var, esc(x)) end

end # module
