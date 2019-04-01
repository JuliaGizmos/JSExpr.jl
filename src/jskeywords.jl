# Escape new macros
function crawlmacro(h::Val{Symbol("@new")}, b)
    return JSAST(:new, [crawl(b)])
end
function deparse(h::Val{:new}, b::JSBody)
    @assert length(b) == 1
    return string("new", " ", deparse(b))
end

# Escape var macros
function crawlmacro(h::Val{Symbol("@var")}, b)
    return JSAST(:var, [crawl(b)])
end
function deparse(h::Val{:var}, b::JSBody)
    @assert length(b) == 1
    return string("var", " ", deparse(b[1]))
end
