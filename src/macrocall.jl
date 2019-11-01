"""
    crawl_macro(Val(:macroname)[, l::LineNumberNode], exprs...)

Crawl a `:macrocall` expression.
This allows certain macro names to be handled specially by JSExpr (such as
`@var` and `@new`).
"""
function crawl_macrocall end

# Allow override-able parsing of macros
function crawl(h::Val{:macrocall}, m::Symbol, l::LineNumberNode, b...)
    return crawl_macrocall(Val(m), l, b...)
end

function crawl_macrocall(m::Val{M}, ::LineNumberNode, b...) where {M}
    # Remove LineNumberNode info to allow for more convenient crawl_macrocall
    # definitions that don't need it.
    return crawl_macrocall(m, b...)
end
