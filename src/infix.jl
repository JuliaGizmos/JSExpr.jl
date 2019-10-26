# For the definitive list of infix operators, examine the Julia parser code:
# https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm#L9
# Most of the infixes are omitted since JavaScript doesn't allow arbitrary
# unicode identifiers and/or the respective infixes don't exist in JavaScript.

# These infix operators have their own distinct head symbols in Julia's AST and
# so we can crawl them as part of the "standard" crawl function.
for infix in (
        :(=), :(+=), :(-=), :(/=), :(*=),
        :(&&), :(||),
)
    # The inner QuoteNode is required so that @eval passes the operator
    # through as a symbol (and not directly interpolating it), and the outer
    # QuoteNode is required so that when crawl returns the Expr, the
    # operator is again passed through as a symbol and not literally
    # interpolated.
    sym = QuoteNode(infix)
    @eval begin
        function crawl(h::Val{$sym}, lhs, rhs)
            # NOTE: We use the `Expr` constructor hear instead of the :(...)
            # syntax to make interpolation easier here.
            return Expr(
                :call,
                :JSAST,
                QuoteNode($sym),
                crawl(lhs),
                crawl(rhs),
            )
        end
        function deparse(h::Val{$sym}, lhs, rhs)
            return jsstring(
                deparse(lhs), " ", string($sym), " ", deparse(rhs),
            )
        end
    end
end

# These infix operators are represented as function calls in Julia's AST and so
# we need to crawl them as part of the `crawl_call` process and deparse them
# into the appropriate infix for JavaScript.
for infix in (
        :+, :-, :*, :/,
        :in, :of, :(==), :(!=), :(===), :(!==),
        :(>), :(<), :(>=), :(<=),
)
    sym = QuoteNode(infix)
    @eval begin
        function crawl_call(::Val{$sym}, lhs, rhs)
            return Expr(
                :call,
                :JSAST,
                QuoteNode($sym),
                crawl(lhs),
                crawl(rhs),
            )
        end
        function deparse(h::Val{$sym}, lhs, rhs)
            return jsstring(
                deparse(lhs), " ", string($sym), " ", deparse(rhs),
            )
        end
    end
end

function crawl(h::Val{:(.)}, lhs, rhs)
    # We unquote the RHS because of the way that Julia adds QuoteNode's to dot
    # expression.
    return :(JSAST(:(.), $(crawl(lhs)), $(crawl(_unquote(rhs)))))
end
function deparse(h::Val{:(.)}, lhs, rhs)
    return js"$(deparse(lhs)).$(deparse(rhs))"
end
