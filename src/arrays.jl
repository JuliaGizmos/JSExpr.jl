# Arrays
function crawl(::Val{:vect}, b...)
    return :(JSAST(:array, $(crawl.(b)...)))
end
function deparse(::Val{:array}, b::JSNode...)::JSString
    return jsstring("[", join(deparse.(b), ","), "]")
end

# Tuples
# TODO: We could extend this syntax to support NamedTuples and convert them to
# objects in JavaScript.
function crawl(::Val{:tuple}, items...)
    return :(JSAST(:(array), $(_crawl_tuple_arg.(items)...)))
end

_crawl_tuple_arg(arg) = crawl(arg)
function _crawl_tuple_arg(arg::Expr)
    if expr.head == :(=)
        error("NamedTuples are not supported by JSExpr.")
    end
    return crawl(arg)
end
