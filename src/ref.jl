function crawl(::Val{:ref}, x)
    return :(JSAST(:ref, $(crawl(x))))
end
function deparse(::Val{:ref}, b::JSNode)::JSString
    return deparse_getindex(b)
end

function deparse_getindex end
function deparse_setindex end
