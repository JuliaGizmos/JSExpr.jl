# Objects
function crawl(h::Val{:tuple}, b::Vararg{Expr, N})::JSNode where N
    js = JSAST(:object)
    for ex in b
        if ex.head == :(=)
            push!(js.args, crawl(ex))
        else
            error("Expression $ex is not a named argument in the tuple.")
        end
    end
    return js
end
function deparse(h::Val{:object}, b::JSNode...)::JSString
    if length(b) > 0
        js = fill(",", 2*length(b) - 1)
        js[1:2:2*length(b) - 1] = deparse.(b)
        js = string("{", js..., "}")
    else
        js = "{}"
    end
    return js
end

crawl(h::Val{:ref}, lhs, rhs) = JSAST(:jsref, [crawl(lhs), crawl(rhs)])
deparse(h::Val{:jsref}, x::JSNode, k::JSNode) = jsstring(
    deparse(x)::JSString,
    "[", deparse(k)::JSString, "]",
)
