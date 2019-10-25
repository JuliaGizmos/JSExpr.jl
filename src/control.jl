# Arrays
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
