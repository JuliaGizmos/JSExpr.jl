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

function crawl_macrocall(m::Val{M}, l::LineNumberNode, b...) where {M}
    if applicable(crawl_macrocall, m, b...)
        return crawl_macrocall(m, b...)
    end

    # For macros, we take the general strategy of just assuming that whatever
    # the macro returns should be interpolated into the JS code.
    return :(JSTerminal(_tojsstring($(esc(eval))(
        Expr(:macrocall, $(esc(M)), $l, $(QuoteNode.(b)...)),
    ))))
end
