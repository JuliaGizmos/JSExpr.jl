"""
    crawlmacro(Val(:macroname), expr)

Dispatch to the correct function to convert a macro call to a `JSNode`. See
`jskeywords.jl` for examples.
"""
function crawlmacro end

# Allow override-able parsing of macros
function crawl(h::Val{:macrocall}, m::Symbol, l::LineNumberNode, b...)

    if hasmethod(crawlmacro, typeof((Val(m), b...)))
        return crawlmacro(Val(m), b...)
    end
    return crawl(macroexpand(@__MODULE__, Expr(:macrocall, m, l, b...); recursive=false))::JSNode
end

# Escape JS macros, treat as terminals
function crawlmacro(h::Val{Symbol("@js-str")}, b::String)
    return crawl(b)
end
