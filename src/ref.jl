function crawl(::Val{:ref}, args...)
    return :(JSAST(:index, $(crawl.(args)...)))
end
function deparse(::Val{:index}, b::JSNode, idx...)::JSString
    return deparse_getindex(b, idx...)
end

function deparse_getindex(b::JSNode, idx::JSNode)
    return jsstring(deparse(b), "[", deparse(idx), "]")
end
function deparse_setindex end
