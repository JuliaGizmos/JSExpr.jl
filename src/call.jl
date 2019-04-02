# Allow override-able parsing of calls
crawl(h::Val{:call}, m::Symbol, b...) = crawl(h, Val(m), b...)

# Default for generic methods
crawl(::Val{:call}, ::Val{M}, args...) where {M} = :(
    JSAST(
        :call,
        $(crawl(M)),
        $(crawl.(args)...)
    )
)

function deparse(::Val{:call}, m, args...)
    jsstring(deparse(m), "(", join(deparse.(args), ", "), ")")
end
