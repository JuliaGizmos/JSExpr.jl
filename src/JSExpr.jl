module JSExpr

using JSON, MacroTools, WebIO
export JSString, @js, @js_str

import WebIO: JSString, JSONContext, JSEvalSerialization

macro js(state, expr)
    :(JSString(string($(jsstring(state, expr)...))))
end

macro js(expr)
    :(JSString(string($(jsstring(Dict(), expr)...))))
end
# Expressions

jsstring(state, x) = _simplify(_flatten(jsexpr(state, x)))

jsexpr(state, x::JSString) = x.s
jsexpr(state, x::Symbol) = (x==:nothing ? "null" : string(x))
jsexpr(state, x) = sprint(x) do io, s
    JSON.show_json(io, JSEvalSerialization(), s)
end
jsexpr(state, x::QuoteNode) = x.value isa Symbol ? jsexpr(state, string(x.value)) : jsexpr(state, x.value)
jsexpr(state, x::LineNumberNode) = nothing

include("util.jl")

function jsexpr_joined(state, xs, delim=",")
    isempty(xs) && return ""
    F(intersperse(jsexpr.((state,), xs), delim))
end

function block_expr(state, args, delim="; ")
    #print(io, "{")
    jsexpr_joined(state, rmlines(args), delim)
    #print(io, "}")
end

function call_expr(state, f, args...)
    if f in [:(=), :+, :-, :*, :/, :%, :(==), :(===),
             :(!=), :(!==), :(>), :(<), :(<=), :(>=)]
        return F(["(", jsexpr_joined(state, args, string(f)), ")"])
    end
    F([jsexpr(state, f), "(", F([jsexpr_joined(state, args)]), ")"])
end

function obs_get_expr(state, x)
    # empty [], special case to get value from an Observable
    F(["WebIO.getval(", jsexpr(state, x), ")"])
end

function obs_set_expr(state, x, val)
    # empty [], special case to get value from an Observable
    F(["WebIO.setval(", jsexpr_joined(state, [x, val]), ")"])
end

function jsexpr(state, o::WebIO.Observable)
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

    jsexpr(state, obsobj)
end

function ref_expr(state, x, args...)
    F([jsexpr(state, x), "[", jsexpr_joined(state, args), "]"])
end

function func_expr(state, args, body)
    parts = []
    named = isexpr(args, :call)
    named || push!(parts, "(")
    push!(parts, "function ")
    if named
        push!(parts, string(args.args[1]))
        args.args = args.args[2:end]
    end
    push!(parts, "(")
    isexpr(args, Symbol) ? push!(parts, string(args)) : push!(parts, jsexpr_joined(state, args.args, ","))
    push!(parts, "){")
    push!(parts, jsexpr(state, insert_return(state, body)))
    push!(parts, "}")
    named || push!(parts, ")")
    F(parts)
end

function insert_return(state, ex)
    if isa(ex, Symbol) || !isexpr(ex, :block)
        Expr(:return, ex)
    else
        isexpr(ex.args[end], :return) && return ex
        ex1 = copy(ex)
        ex1.args[end] = insert_return(state, ex.args[end])
        ex1
    end
end


function dict_expr(state, xs)
    parts = []
    xs = map(xs) do x
        if x.head == :(=) || x.head == :kw
            push!(parts, F([jsexpr(state, x.args[1]), ":", jsexpr(state, x.args[2])]))
        elseif x.head == :call && x.args[1] == :(=>)
            push!(parts, F([jsexpr(state, x.args[2]), ":", jsexpr(state, x.args[3])]))
        else
            error("Invalid pair separator in dict expression")
        end
    end
    F(["{", F(intersperse(parts, ",")), "}"])
end

function vect_expr(state, xs)
    F(["[", F(intersperse([jsexpr(state, x) for x in xs], ",")), "]"])
end

function if_block(state, ex)

    if isexpr(ex, :block)
        if any(x -> isexpr(x, :macrocall) && x.args[1] == Symbol("@var"), ex.args)
            error("@js expression error: @var inside an if statement is not supported")
        end
        F(["(", block_expr(state, rmlines(ex).args, ", "), ")"])
    else
        jsexpr(state, ex)
    end
end

function if_expr(state, xs)
    parts = []
    if length(xs) >= 2    # we have an if
        append!(parts, [jsexpr(state, xs[1]), " ? ", if_block(state, xs[2])])
    end

    if length(xs) == 3    # Also have an else
        append!(parts, [" : ", if_block(state, xs[3])])
    else
        push!(parts, " : undefined")
    end
    F(parts)
end

function for_expr(state, i, start, to, body, step = 1)
    F(["for(var $i = $start; $i <= $to; $i = $i + $step){",
       block_expr(state, body), "}"])
end

function jsexpr(state, x::Expr)
    isexpr(x, :block) && return block_expr(state, rmlines(x).args)
    x = rmlines(x)
    @match x begin
        d(xs__) => dict_expr(state, xs)
        Dict(xs__) => dict_expr(state, xs)
        $(Expr(:comparison, :_, :(==), :_)) => jsexpr_joined(state, [x.args[1], x.args[3]], "==")    # 0.4

        # must include this particular `:call` expr before the catchall below
        $(Expr(:call, :(==), :_, :_)) => jsexpr_joined(state, [x.args[2], x.args[3]], "==")    # 0.5+
        f_(xs__) => call_expr(state, f, xs...)
        (a_ -> b_) => func_expr(state, a, b)
        a_.b_ | a_.(b_) => jsexpr_joined(state, [a, b], ".")
        (a_[] = val_) => obs_set_expr(state, a, val)
        (a_ = b_) => jsexpr_joined(state, [a, b], "=")
        (a_ += b_) => jsexpr_joined(state, [a, b], "+=")
        (a_ && b_) => jsexpr_joined(state, [a, b], "&&")
        (a_ || b_) => jsexpr_joined(state, [a, b], "||")
        $(Expr(:if, :__)) => if_expr(state, x.args)
        $(Expr(:function, :__)) => func_expr(state, x.args...)
        a_[] => obs_get_expr(state, a)
        a_[i__] => ref_expr(state, a, i...)
        [xs__] => vect_expr(state, xs)
        (@m_ xs__) => jsexpr(state, macroexpand(JSExpr, x))
        (for i_ = start_ : to_
            body__
        end) => for_expr(state, i, start, to, body)
        (for i_ = start_ : step_ : to_
            body__
        end) => for_expr(state, i, start, to, body, step)
        (return a__) => (F(["return ", !isempty(a) && a[1] !== nothing ? jsexpr(state, a...) : ""]))
        $(Expr(:quote, :_)) => jsexpr(state, QuoteNode(x.args[1]))
        $(Expr(:$, :_)) => inter(state, x.args[1])
        $(Expr(:new, :c_)) => F(["new ", jsexpr(state, x.args[1])])
        $(Expr(:var, :c_)) => F(["var ", jsexpr(state, x.args[1])])
        _ => error("JSExpr: Unsupported `$(x.head)` expression, $x")
    end
end

function inter(state, x)
    if x isa Expr && x.args[1] isa Expr
        x.args[1].head == :...
        return :(join(map(e->jsexpr(state, e), $(esc(x.args[1].args[1]))), ","))
    end
    :(jsexpr($(esc(state)), $(esc(x)))) # the expr gets kept around till eval
end

macro new(x) Expr(:new, esc(x)) end
macro var(x) Expr(:var, esc(x)) end

end # module
