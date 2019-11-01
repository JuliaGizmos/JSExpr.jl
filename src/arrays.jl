# Arrays
function crawl(::Val{:vect}, b...)
    return :(JSAST(:array, $(crawl.(b)...)))
end
function deparse(::Val{:array}, b::JSNode...)::JSString
    return jsstring("[", join(deparse.(b), ","), "]")
end

# Tuples
function crawl(::Val{:tuple}, items...)
    # This is defined in objecs.jl.
    if _is_namedtuple(items...)
        return _crawl_namedtuple(items...)
    end
    return :(JSAST(:array, $(crawl.(items)...)))
end
