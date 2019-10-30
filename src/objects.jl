crawl(::Val{:braces}, args...) = _crawl_dict(args...)
crawl_call(::Val{:Dict}, args...) = _crawl_dict(args...)

function _crawl_dict(args...)
    return :(JSAST(
        :object,
        $(_crawl_objectpair.(args)...)
    ))
end

function _crawl_objectpair(expr)
    if !(expr isa Expr && expr.head == :call && expr.args[1] == :(=>))
        error("Invalid object pair (expected => expression, got $(expr)).")
    end
    return :(
        JSAST(:objectpair, $(crawl.(expr.args[2:3])...))
    )
end

function deparse(::Val{:object}, pairs...)
    return jsstring(
        "{",
        join(deparse.(pairs), ","),
        "}",
    )
end

function deparse(::Val{:objectpair}, key, value)
    return jsstring(
        "[", deparse(key), "]: ",
        deparse(value),
    )
end

"""
Determine whether the tuple expression with args `items` is a namedtuple.

This is used when crawling tuples, which is defined in `arrays.jl`.
"""
function _is_namedtuple(items...)
    if isempty(items)
        return false
    end
    firstelt = first(items)
    return firstelt isa Expr && firstelt.head == :(=)
end

function _crawl_namedtuple(items...)
    return :(JSAST(:object, $(_crawl_namedtuple_arg.(items)...)))
end

function _crawl_namedtuple_arg(item)
    if !(item isa Expr && item.head == :(=))
        error("Invalid namedtuple item (expected = expression, got $(item)).")
    end
    lhs, rhs = item.args
    if !(lhs isa Symbol)
        error("Invalid namedtuple key (expected Symbol, got $(lhs)).")
    end
    return :(JSAST(:objectpair, JSTerminal($(string(lhs))), $(crawl(rhs))))
end
