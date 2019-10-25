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
