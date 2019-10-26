# Escape new macros
function crawl_macrocall(h::Val{Symbol("@new")}, b)
    return :(JSAST(:new, $(crawl(b))))
end
function deparse(h::Val{:new}, b::JSNode)
    return jsstring("new", " ", deparse(b))
end

# Escape var macros
function crawl_macrocall(h::Val{Symbol("@var")}, b)
    return :(JSAST(:var, $(crawl(b))))
end
function deparse(h::Val{:var}, b::JSNode)
    return jsstring("var", " ", deparse(b))
end

# Escape const macros
function crawl_macrocall(h::Val{Symbol("@const")}, b)
    return :(JSAST(:const, $(crawl(b))))
end
function deparse(h::Val{:const}, b::JSNode)
    return jsstring("const", " ", deparse(b))
end

# Escape let macros
function crawl_macrocall(h::Val{Symbol("@let")}, b)
    return :(JSAST(:let, $(crawl(b))))
end
function deparse(h::Val{:let}, b::JSNode)
    return jsstring("let", " ", deparse(b))
end
