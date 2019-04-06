abstract type JSNode end

"""
    JSTerminal(s)

A JavaScript terminal node.
Any JavaScript literal is represented as a `JSTerminal` node.
"""
struct JSTerminal <: JSNode
    s::JSString
end

JSTerminal(x::Union{Symbol, Number, Bool}) = JSTerminal(JSString(string(x)))
JSTerminal(x::String) = JSTerminal(js"$x")
JSTerminal(::Nothing) = JSTerminal(js"null")

"""
    JSAST(head[, body])

A struct that represents an abstract syntax tree for a JavaScript expression.
This is meant to be analogous to the Julia builtin `Expr`.
"""
struct JSAST <: JSNode
    head::Symbol
    args::Vector{JSNode}
end

JSAST(h) = JSAST(h, [])
JSAST(h, body::Union{JSNode, Nothing}...) = JSAST(h, [b for b in body if nothing !== b])

# Custom show methods to make printing look less noisy.
Base.show(io:: IO, m::MIME"text/plain", t::JSTerminal) = print(io, "JSTerminal($(t.s.s))")
function Base.show(io:: IO, m::MIME"text/plain", t::JSAST)
    print(io, "JSAST(", QuoteNode(t.head))
    foreach(t.args) do x
        print(io, ", ")
        Base.show(io, m, x)
    end
    print(io, ")")
end
