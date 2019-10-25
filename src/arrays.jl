# Arrays
function crawl(h::Val{:vect}, b...)
    return :(JSAST(:array, $(crawl.(b)...)))
end
function deparse(h::Val{:array}, b::JSNode...)::JSString
    return jsstring("[", join(deparse.(b), ","), "]")
end

# Tuples
# TODO: We could extend this syntax to support NamedTuples and convert them to
# objects in JavaScript.
function crawl(h::Val{:tuple}, items...)
    return :(JSAST(:array, $(crawl_tuple_arg.(items)...)))
end

crawl_tuple_arg(arg) = crawl(arg)
function crawl_tuple_arg(arg::Expr)
    if expr.head == :(=)
        error("NamedTuples are not supported by JSExpr.")
    end
    return crawl(arg)
end
