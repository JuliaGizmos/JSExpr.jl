module JSExpr

# Note: we re-export @js_str for convenience from WebIO.
# In the future(?) we might move JSString from WebIO to JSExpr.jl and reverse
# the direction of the dependencies.
export @js, @js_str

using WebIO: JSString, @js_str, tojs

JSString(s::JSString) = s # Definitely move this into WebIO.
jsstring(xs::JSString...) = JSString(string([x.s for x in xs]...))
jsstring(xs...) = jsstring(JSString.(xs)...)

include("./ast.jl")

"""
    crawl(expr)

Crawl a given Julia expression and convert it into a `JSNode`.

There are to versions of `crawl`. The former (`crawl(expr)`) crawls an entire
expression recursively and converts it into a `JSNode`.

# Examples
```julia-repl
julia> JSExpr.crawl(:(foo = "bar"))
:(JSAST(:(=), JSTerminal(:foo), JSTerminal("bar")))
```
"""
function crawl(ex::Expr)::Expr
    crawl(Val(ex.head), ex.args...)
end

"""
    crawl(Val(head), args...)

Enables multiple dispatch on expressions using `Val` types.
The expectation is that each dispatched crawl function returns an expression
that yields a `JSNode` by calling the crawl-function recursively on deeper
expressions.

# Examples
```julia
function crawl(::Val{:+}, lhs, rhs)
    :(JSAST(:+, \$(crawl(lhs)), \$(crawl(rhs))))
end
```
"""
function crawl(::Val{T}, args...)::Expr where {T}
    error("Expression type ($(QuoteNode(T))) not supported.")
end

"""
    deparse(jsnode)

The expectation is that each dispatched deparse function returns a bare JSString
literal, formed by appropriate ordering and concatenation of the output of
recursive calls to the deparse-function.

Convert a `JSNode` to `JSString`.
"""
function deparse(ex::JSAST)::JSString
    deparse(Val(ex.head), ex.args...)::JSString
end

function deparse(::Val{H}, args...) where {H}
    # This should only happen if there is an asymmetry between crawl and
    # deparse; for example, if crawl is implemented but deparse was forgotten,
    # or crawl generates a JSAST with more arguments than the deparse method
    # supports.
    error("JSAST expression type ($(QuoteNode(H))) cannot be deparsed.")
end

"""
    @js(ex)

A macro to convert a Julia expression into a `JSString`.
"""
macro js(ex)
    return Expr(:call, :deparse, crawl(ex))
end

"""
    @crawl(ex)

A macro to generate a `JSNode` for the given expression.
This is useful for making assertions about the generated AST structure, which
is in turn useful for testing, but most users should just use `@js`.
"""
macro crawl(ex)
    crawl(ex)
end

# I'm pretty sure QuoteNodes can be safely ignored.
crawl(ex::QuoteNode) = crawl(ex.value)

# All other terminals
function crawl(ex::T) where {T}

    # Push terminals that have native symbol methods, maybe unsafe
    if hasmethod(JSTerminal, Tuple{T})
        return :(JSTerminal($(esc(ex))))

    # Push terminals, when all else fails try interpolation. This will be a source of bugs
    # because there are no guarantees the string representation will be sensible.
    elseif hasmethod(string, Tuple{T})
        return :(JSTerminal(JSString(string($(esc(ex))))))

    # Bail and explain
    else
        error(
            "The type $T cannot be a terminal node because " *
            "neither a string method nor a Symbol method were found."
        )
    end
end

include("./literals.jl")
include("./call.jl")
include("./infix.jl")
include("./macrocall.jl")
include("./objects.jl")
include("./arrays.jl")
include("./jskeywords.jl")
include("./interpolation.jl")

end
