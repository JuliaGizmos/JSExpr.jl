# "Standard" infix operators
for infix in (:(=), :(+=), :(-=), :(/=), :(*=))
    # The inner QuoteNode is required so that @eval passes the operator
    # through as a symbol (and not directly interpolating it), and the outer
    # QuoteNode is required so that when crawl returns the Expr, the
    # operator is again passed through as a symbol and not literally
    # interpolated.
    sym = QuoteNode(infix)
    @eval begin
        crawl(h::Val{$sym}, lhs, rhs) = Expr(
            :call,
            :JSAST,
            QuoteNode($sym),
            crawl(lhs),
            crawl(rhs),
        )
        deparse(h::Val{$sym}, lhs, rhs) = jsstring(
            deparse(lhs), " ", string($sym), " ", deparse(rhs),
        )
    end
end

# Take care of infix operators that are translated to calls in the Julia AST
# (We need to translate them back into infix operators for the JSAST).
for infix in (:+, :-, :*, :/)
    sym = QuoteNode(infix)
    @eval begin
        crawl(::Val{:call}, ::Val{$sym}, lhs, rhs) = Expr(
            :call,
            :JSAST,
            QuoteNode($sym),
            crawl(lhs),
            crawl(rhs),
        )
        deparse(h::Val{$sym}, lhs, rhs) = jsstring(
            deparse(lhs), " ", string($sym), " ", deparse(rhs),
        )
    end
end

function crawl(h::Val{:(.)}, lhs, rhs)
    :(JSAST(:(.), $(crawl(lhs)), $(crawl(rhs))))
end
function deparse(h::Val{:(.)}, lhs, rhs)
    js"$(deparse(lhs)).$(deparse(rhs))"
end
