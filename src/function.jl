crawl(h::Val{:function}, signature, body) = :(
    JSAST(
        :function,
        $(crawl(signature)),
        $(crawl(body)),
    )
)
deparse(h::Val{:function}, signature, body) = jsstring(
    "function ", deparse(signature), " ", deparse(body),
)

crawl(h::Val{:(->)}, arguments, body) = :(
    JSAST(
        :function,
        $(arrowarguments2call(arguments)),
        $(crawl(body)),
    )
)

crawl(h::Val{:return}, ex) = :(
    JSAST(
        :return,
        $(crawl(ex)),
    )
)
deparse(h::Val{:return}, ex) = jsstring(
    "return ", deparse(ex)
)

crawl(::Val{:block}, body...) = :(
    JSAST(
        :block,
        $(crawl.(body)...),
    )
)

deparse(::Val{:block}) = error("Block expression must be nonempty.")
deparse(::Val{:block}, body...) = jsstring(
    "{ ",
    join(deparse.([
        body[1:length(body)-1]...
        returnify(last(body))
    ]), "; "),
    "; }"
)

function returnify(statement::JSNode)
    if isa(statement, JSAST) && statement.head == :return
        return statement
    end
    return JSAST(:return, statement)
end

"""
    arguments2call(expr)

Convert arrow function arguments to a `JSAST` with head `call`.
This works by turning a tuple of arguments (or a symbol in the case of a single
argument) into a `call` whose function name is an empty string (which matches
the javascript syntax where the function signature looks like a call but with
an optional function name).
"""
function arrowarguments2call(ex::Expr)
    if ex.head != :tuple
        error("Cannot convert non-tuple expression to a call.")
    end
    # This is kind of a hack but we convert this to a call with an empty
    # function name since a call is expected to be the head of a JSAST for a
    # function declaration.
    return :(JSAST(
        :call,
        JSTerminal(JSString("")),
        $(crawl.(ex.args)...),
    ))
end

arrowarguments2call(ex::Symbol) = :(
    JSAST(
        :call,
        JSTerminal(JSString("")),
        $(crawl(ex)),
    )
)
