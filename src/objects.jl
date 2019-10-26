crawl(::Val{:braces}, args...) = crawl_dict(args...)
crawl_call(::Val{:Dict}, args...) = crawl_dict(args...)

function crawl_dict(args...)
    return :(JSAST(
        :object,
        $(crawl_objectpair.(args)...)
    ))
end

function crawl_objectpair(expr)
    if !(expr.head == :call && expr.args[1] == :(=>))
        error("Invalid object pair (expected => expression).")
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
