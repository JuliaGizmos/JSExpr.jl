# See documentation for `crawl_call` for documentation on what we're doing here.
function crawl(::Val{:call}, f, args...)
    return :(JSAST(
        :call,
        $(crawl(f)),
        $(crawl.(args)...),
    ))
end
function crawl(::Val{:call}, f::Symbol, args...)
    return crawl_call(f, args...)
end

"""
Crawl a _simple_ function call.

_Simple_ is defined to be a function call where the function name is a symbol.
In general, the function name may be any expression (e.g., in
`@js console.log("foo")`, the function `console.log` is not a symbol and has its
own JSAST since it's using the dot-operator). However, for simple cases, when
the function is just a symbol, we can dispatch to the `crawl_call` function to
perform further transformation if necessary.

This is useful for transforming syntactic constructs which are represented in
Julia as function calls (e.g. we transform `+(1, 2)` into `1 + 2`), as well as
for translating some Julia-isms.
"""
function crawl_call(f::Symbol, args...)
    return crawl_call(Val(f), args...)
end

# Default for generic methods
crawl_call(::Val{M}, args...) where {M} = :(
    JSAST(
        :call,
        $(crawl(M)),
        $(crawl.(args)...),
    )
)

function deparse(::Val{:call}, f, args...)
    jsstring(deparse(f), "(", join(deparse.(args), ", "), ")")
end
