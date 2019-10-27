# For the definitive list of infix operators, examine the Julia parser code:
# https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm#L9
# Most of the infixes are omitted since JavaScript doesn't allow arbitrary
# unicode identifiers and/or the respective infixes don't exist in JavaScript.

# TODO:
# It would make sense (and might make things a bit easier/cleaner) to map infix
# and unary expressions into JSAST's with :infixop and :unaryop heads
# respectively.
# This means that 1 + 2 would become (:infixop, :+, 1, 2) instead of (:+, 1, 2).
# We would only need to have one deparse method for all infixes, and this allows
# us to disambiguate unary from infix at the JSAST level (instead of checking if
# length(jsast.args) > 1).

"""
    _isinfix(arg[, exclude_infix])

Returns true if arg is an infix symbol or infix JSNode unless it matches the
symbol provided for exclude.
"""
function _isinfix end

# _isinfix(::Symbol)
_isinfix(s::Symbol, x::Union{Symbol, Nothing}=nothing) = _isinfix(Val(s), x)
_isinfix(::Val{S}) where {S} = false
function _isinfix(val::Val{S}, x::Union{Symbol, Nothing}) where {S}
    return S != x && _isinfix(val)
end

# _isinfix(::JSNode)
_isinfix(::JSNode, x::Union{Symbol, Nothing}=nothing) = false
function _isinfix(j::JSAST, x::Union{Symbol, Nothing}=nothing)
    # We check j.args > 1 here to avoid redundant parenthesization around unary
    # operators. See TODO comment at start of this file.
    return _isinfix(j.head, x) && length(j.args) > 1
end

"""
Deparse an argument to an infix operator.

This is used to provide intelligent parenthesization when deparsing infix
operators. The use of the `exclude_infix` arg is to avoid redundant parentheses
around operators of the same type (this is necessary so that
`foo && bar && spam` in Julia is not deparsed as `foo && (bar && spam)` in JS).

NOTE: The exclusion argument is, strictly speaking, only necessary for
short-circuiting operators since they aren't represented as multiple-argument
functions in Julia's AST. So `1 + 2 + 3` becomes `(+ 1 2 3)` but
`foo && bar && spam` becomes `(&& foo (&& bar spam))`.
"""
function _deparse_infix_arg(arg::JSNode, exclude_infix=nothing)
    if !_isinfix(arg, exclude_infix)
        return deparse(arg)
    end
    return jsstring("(", deparse(arg), ")")
end

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
        _isinfix(::Val{$sym}) = true
        function crawl(h::Val{$sym}, args...)
            # NOTE: We use the `Expr` constructor hear instead of the :(...)
            # syntax to make interpolation easier here.
            return Expr(
                :call,
                :JSAST,
                QuoteNode($sym),
                crawl.(args)...,
            )
        end
        function deparse(::Val{$sym}, args...)
            return jsstring(
                join(_deparse_infix_arg.(args, $sym), string(" ", $sym, " "))
            )
        end
    end
end

# These infix operators are represented as function calls in Julia's AST and so
# we need to crawl them as part of the `crawl_call` process and deparse them
# into the appropriate infix for JavaScript.
# NOTE: For arithmetic operators (like `+` and `*`), if multiple are chained
# together, Julia generates a :call Expr with multiple arguments, so we need to
# handle crawling and deparsing `+(arg1, args2, args...)`.
# NOTE: For comparison operators (like `>=` and `==`), when multiple are
# chained, Julia generates an Expr with a :comparison head that lets us do
# things like `0 <= x <= 1`. We could potentially translate that to equivalent
# JavaScript (though we'd have to translate it as `0 <= x && x <= 1`).
for infix in (
        :+, :-, :*, :/,
        :in, :of, :(==), :(!=), :(===), :(!==),
        :(>), :(<), :(>=), :(<=),
)
    sym = QuoteNode(infix)
    @eval begin
        _isinfix(::Val{$sym}) = true
        function crawl_call(::Val{$sym}, arg1, arg2, args...)
            return Expr(
                :call,
                :JSAST,
                QuoteNode($sym),
                crawl.([arg1, arg2, args...])...,
            )
        end
        function deparse(::Val{$sym}, arg1, arg2, args...)
            return jsstring(
                join(
                    _deparse_infix_arg.([arg1, arg2, args...]),
                    string(" ", $sym, " "),
                )
            )
        end
    end
end

# Unary operators
for unary in (
        :+, :-,
)
    sym = QuoteNode(unary)
    @eval begin
        function crawl_call(::Val{$sym}, arg)
            return Expr(
                :call,
                :JSAST,
                QuoteNode($sym),
                crawl(arg),
            )
        end
        function deparse(::Val{$sym}, arg)
            return jsstring(
                string($sym),
                _isinfix(arg)
                    ? string("(", deparse(arg), ")")
                    : deparse(arg)
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
