function crawl(h::Val{:(=)}, lhs, rhs)
    JSAST(:(=), [crawl(lhs), crawl(rhs)])
end
function deparse(h::Val{:(=)}, b::JSBody)
    jsstring(deparse(b[1])::JSString, " = ", deparse(b[2])::JSString)
end
