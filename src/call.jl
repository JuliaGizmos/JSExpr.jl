# Generically, the method may be any expression
# e.g. In ``@js console.log("foo")`, the method has it's own AST since it's
# using the dot-operator (`.`).
crawl(h::Val{:call}, f, args...) = :(
    JSAST(
        :call,
        $(crawl(f)),
        $(crawl.(args)...),
    )
)

# But for simple cases, we can allow for dispatching based on the method name.
crawl(h::Val{:call}, m::Symbol, args...) = crawl(h, Val(m), args...)

# Default for generic methods
crawl(::Val{:call}, ::Val{M}, args...) where {M} = :(
    JSAST(
        :call,
        $(crawl(M)),
        $(crawl.(args)...),
    )
)

function deparse(::Val{:call}, m, args...)
    jsstring(deparse(m), "(", join(deparse.(args), ", "), ")")
end
