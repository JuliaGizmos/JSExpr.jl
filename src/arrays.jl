# Arrays
function crawl(h::Val{:vect}, b...)
    return :(JSAST(:array, $(crawl.(b))))
end
function deparse(h::Val{:array}, b::JSNode...)::JSString
    return jsstring("[", join(deparse.(b), ", "), "]")
end
