function crawl(::Val{:if}, test, consequent, alternate=nothing)
    return _crawl_if(:if, test, consequent, alternate)
end

function crawl(::Val{:elseif}, test, consequent, alternate=nothing)
    # There's some weirdness in the way Julia parses `if ... elseif ...`.
    # It wraps the test expression in a block (probably to include the
    # LineNumberNode information).
    @assert (test isa Expr && test.head == :block) "Unparseable :elseif expression."
    test_args = filter(x -> !isa(x, LineNumberNode), test.args)
    @assert (length(test_args) == 1) "Invalid test in :elseif expression ($(test_args))."
    test = test_args[1]
    return _crawl_if(:elseif, test, consequent, alternate)
end

function _crawl_if(head::Symbol, test, consequent, alternate)
    body = crawl.(
        alternate === nothing
        ? [test, consequent]
        : [test, consequent, alternate]
    )
    return :(JSAST($(QuoteNode(head)), $(body...)))
end

function deparse(
        ::Val{:if},
        test::JSNode,
        consequent::JSNode,
        alternate::Union{JSNode, Nothing} = nothing
)::JSString
    return jsstring(
        "if (", deparse(test), ") ",
        deparse(consequent),
        _deparse_if_alternate(alternate),
    )
end

# The alternate of an if statement be nothing, an "else" clause (in which case,
# the head of the expression is simply a block), or an "elseif" (in which case
# the head of the expression is :elseif).
_deparse_if_alternate(::Nothing) = jsstring("")
function _deparse_if_alternate(expr::JSNode)
    if expr.head == :elseif
        return jsstring(
            # This is a hack that uses the fact that we can treat the args of an
            # elseif as an if and just change the initial "if" to "elseif".
            " else", deparse(Val(:if), expr.args...)
        )
    elseif expr.head == :block
        return jsstring(" else ", deparse(expr))
    end
    error(
        "Invalid alternate expression in :if expression " *
        "(expected :elseif or :block expression, got $(expr))."
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
