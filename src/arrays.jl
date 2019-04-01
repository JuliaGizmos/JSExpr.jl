# Arrays
function crawl(h::Val{:vect}, b...)::JSNode
    return JSAST(:array, crawl.(b))
end
function deparse(h::Val{:array}, b::JSBody)::JSString
    b = deparse.(b)
    return jsstring("[", join(b, ", "), "]")
end
