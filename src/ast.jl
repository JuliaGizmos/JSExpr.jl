"""
    JSSymbol(s)

A JavaScript symbol. Our definition of symbol is a bit broader than Julia's
definition since we also include all literals.

TODO: Rename to `JSTerminal`?
"""
struct JSSymbol
    s::JSString
end

JSSymbol(s::Symbol) = JSSymbol(JSString(string(s)))
JSSymbol(x::Union{Number, Bool}) = JSSymbol(JSString(string(x)))

"""
    JSAST(head[, body])

A struct that represents an abstract syntax tree for a JavaScript expression.
This is meant to be analogous to the builtin `Expr`.
"""
struct JSAST
    head::Symbol
    args::Vector{Union{JSAST, JSSymbol}}
    # function JSAST(
    #     h::Symbol,
    #     # b::Union{Vector{JSAST}, Vararg{JSAST, N}} = Vector{JSAST}()
    #     b::Union{Vector{Union{JSAST, JSSymbol}}, Tuple{Union{JSAST, JSSymbol}}} = Vector{Union{JSAST, JSSymbol}}()
    # ) where N
    #     if isa(b, Vector)
    #         return new(h, b)
    #     else
    #         return new(h, [b...])
    #     end
    # end

    JSAST(h) = new(h, [])
    JSAST(h, body::Tuple) = new(h, convert(Vector{Union{JSAST, JSSymbol}}, [body...]))
    JSAST(h, body::Array) = new(h, convert(Vector{Union{JSAST, JSSymbol}}, body))
    JSAST(h, body::Union{JSAST, JSSymbol}...) = new(h, [body...])
end

const JSNode = Union{JSAST, JSSymbol}
const JSBody = Vector{JSNode}
