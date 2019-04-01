module JSExpr

using WebIO: JSString, @js_str

JSString(s::JSString) = s # Definitely move this into WebIO.
jsstring(xs::JSString...) = JSString(string([x.s for x in xs]...))
jsstring(xs...) = jsstring(JSString.(xs)...)

include("./ast.jl")

"""
    crawl(expr)
    crawl(head, ...)

Crawl a given expression and convert it into a `JSNode`.

There are to versions of `crawl`. The former (`crawl(expr)`) crawls an entire
expression recursively and converts it into a `JSNode`. The latter form is to
enable multiple dispatch on expressions using `Val` types.

The expectation is that each dispatched crawl function returns a JSNode by
calling the crawl-function recursively on deeper expressions.

# Examples
```julia
crawl(:(foo = "bar"))
```
"""
function crawl(ex::Expr)::JSNode
    # Recurse into expressions
    if hasmethod(crawl, typeof((Val(ex.head), ex.args...)))
        return crawl(Val(ex.head), ex.args...)::JSNode
    # Bail and explain
    else
        error("Expression $ex not supported.")
    end
end

"""
    deparse(jsnode)
    deparse(head, args...)

The expectation is that each dispatched deparse function returns a bare JSString
literal, formed by appropriate ordering and concatenation of the output of
recursive calls to the deparse-function.

Convert a `JSNode` to `JSString`.
"""
function deparse(ex::JSAST)::JSString
    deparse(Val(ex.head), ex.args)::JSString
end

include("./literals.jl")
include("./infix.jl")

# Dumps the raw JS string literal into the argument of the parent
# expression that the macro was called from. The common use
# cases are for the macro to be called as the RHS of an assignment,
# or an interpolation into another literal.
macro js(ex)
    return Expr(:call, :JSString, deparse(crawl(ex)))
end

# All other terminals
function crawl(ex::T)::JSNode where {T}

    # Push terminals that have native symbol methods, maybe unsafe
    if hasmethod(JSSymbol, Tuple{T})
        return JSSymbol(ex)

    # Push terminals, when all else fails try interpolation. This will be a source of bugs
    # because there are no guarantees the string representation will be sensible.
    elseif hasmethod(string, Tuple{T})
        return JSSymbol(JSString(string(ex)))

    # Bail and explain
    else
        error(
            "The type $T cannot be a terminal node because " *
            "neither a string method nor a Symbol method were found."
        )
    end
end

include("./call.jl")
include("./macrocall.jl")
include("./objects.jl")
include("./arrays.jl")
include("./jskeywords.jl")

end
