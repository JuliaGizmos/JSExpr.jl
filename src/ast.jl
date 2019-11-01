"""
A node that represents a piece of a JavaScript abstract syntax tree.

Every node is either a [`JSAST`](@ref) (_i.e._, non-terminal node) or a
[`JSTerminal`](@ref).
"""
abstract type JSNode end

"""
    JSTerminal(s::JSString)

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
    JSAST(head::Symbol, args::JSNode...)

A struct that represents an abstract syntax tree for a JavaScript expression.
This is meant to be analogous to Julia's `Expr`s.
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

_unquote(x) = x
_unquote(x::QuoteNode) = _unquote(x.value)
