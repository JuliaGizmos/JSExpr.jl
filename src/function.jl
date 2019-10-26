crawl(h::Val{:function}, signature, body) = :(
    JSAST(
        :function,
        $(crawl(signature)),
        $(crawl(body)),
    )
)
function deparse(::Val{:function}, signature, body)
    return jsstring(
        "function ", deparse(signature), " ",
        deparse(body),
    )
end

# NOTE: We need to treat arrow functions differently than normal functions
# because of the way `this` binding works in JS using arrow functions (i.e.,
# its invalid to transform () -> ... into JavaScript that uses the function
# keyword instead of the => JavaScript syntax).
function crawl(::Val{:(->)}, arguments, body)
    return :(JSAST(
        :arrowfunction,
        $(arrowarguments2call(arguments)),
        $(crawl(body)),
    ))
end
function deparse(::Val{:arrowfunction}, signature, body)
    return jsstring(
        deparse(signature), " => ",
        deparse_returnify_block(body),
    )
end

function crawl(h::Val{:return}, ex)
    return :(JSAST(
        :return,
        $(crawl(ex)),
    ))
end
function deparse(h::Val{:return}, ex)
    return jsstring("return ", deparse(ex))
end

function crawl(::Val{:block}, body...)
    return :(JSAST(
        :block,
        $(crawl.(body)...),
    ))
end
function deparse(::Val{:block}, body...)
    if length(body) == 0
        error(
            "Invalid JS block expression: " *
            "must contain at least one statement."
        )
    end
    return jsstring("{ ", join(deparse.(body), "; "), "; }")
end

function returnify_js_statement(statement::JSNode)
    if !isa(statement, JSAST)
        return JSAST(:return, statement)
    end

    head = statement.head
    if head == :return
        return statement
    elseif head == :if
        statement.args[2] = returnify_js_statement(statement.args[2])
        if length(statement.args) > 2
            statement.args[3] = returnify_js_statement(statement.args[3])
        end
        return statement
    elseif head == :block
        statement.args[end] = returnify_js_statement(statement.args[end])
        return statement
    elseif in(head, (:while, :for))
        # We give up trying to add implicit returns if it's "too hard".
        return statement
    end
    return JSAST(:return, statement)
end

"""
Deparse a block, transforming its final statement into a return statement.

This ensures that Julia semantics wherein the last expression is implicitly the
return value is translated to the generated JavaScript code (as is necessary
for arrow functions to work as expected).
"""
function deparse_returnify_block(block::JSNode)
    if !(isa(block, JSAST) && block.head == :block)
        @show block
        error("Argument to returnify_block must be a JSAST(:block, ...).")
    end
    block.args[end] = returnify_js_statement(block.args[end])
    return deparse(block)
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
