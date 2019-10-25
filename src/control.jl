# If
function crawl(::Val{:if}, test, consequent, alternate=nothing)
    body = crawl.(
        alternate === nothing
        ? [test, consequent]
        : [test, consequent, alternate]
    )
    return :(JSAST(:if, $(body...)))
end
function deparse(
        ::Val{:if},
        test::JSNode,
        consequent::JSNode,
        alternate::Union{JSNode, Nothing} = nothing
)::JSString
    alternate_string = (
        alternate === nothing
        ? jsstring("")
        : jsstring(" else ", deparse(alternate))
    )
    return jsstring(
        "if (", deparse(test), ") ",
        deparse(consequent),
        alternate_string,
    )
end

# While
function crawl(::Val{:while}, test, body)
    return :(JSAST(:while, $(crawl(test)), $(crawl(body))))
end
function deparse(
        ::Val{:while},
        test::JSNode,
        body::JSNode,
)::JSString
    return jsstring(
        "while (", deparse(test), ") ",
        deparse(body),
    )
end

# For
function crawl(::Val{:for}, iterspec, body)
    return :(JSAST(
        :for,
        $(crawl_iterspec(iterspec)),
        $(crawl(body)),
    ))
end
function deparse(::Val{:for}, iterspec, body)
    return jsstring(
        "for (", deparse(iterspec), ") ",
        deparse(body),
    )
end

"""
Transform a Julia iteration specification into JavaScript.

Importantly, this transforms `for x in iterable` in Julia into
`for x of iterable` in JavaScript (since `of` is more often what is desired).
"""
function crawl_iterspec(iterspec)
    # In the future, we might be able to transform compound iteration
    # specifications (such as `for i = 1:10, j = i:10`) into nested for loops,
    # but for now, we don't support that syntax.
    if iterspec.head != :(=)
        error(
            "Compound iteration specifications in for loops " *
            "are not supported by JSExpr."
        )
    end
    lhs, rhs = iterspec.args
    return :(JSAST(
        :of,
        JSAST(
            :let,
            $(crawl(lhs)),
        ),
        $(crawl(rhs)),
    ))
end

for keyword in (:break, :continue)
    sym = QuoteNode(keyword)
    @eval function crawl(::Val{$sym})
        return Expr(
            :call,
            JSTerminal,
            JSString($(string(keyword))),
        )
    end
end
