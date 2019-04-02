crawl(h::Val{:(=)}, lhs, rhs) = :(
    JSAST(:(=), $(crawl(lhs)), $(crawl(rhs)))
)
function deparse(h::Val{:(=)}, b::JSNode...)
    jsstring(deparse(b[1])::JSString, " = ", deparse(b[2])::JSString)
end

function crawl(h::Val{:(.)}, lhs, rhs)
    :(JSAST(:(.), $(crawl(lhs)), $(crawl(rhs))))
end
function deparse(h::Val{:(.)}, lhs, rhs)
    js"$(deparse(lhs)).$(deparse(rhs))"
end
