# "Fundamental" literals
crawl(ex::String) = :(JSTerminal($ex))
crawl(b::Bool) = crawl(Symbol(b))

# Symbols
# We sub-dispatch on symbols to allow for special handling of certain keywords.
crawl(sym::Symbol) = crawl_symbol(Val(sym))
function crawl_symbol(sym::Val{S}) where {S}
    return :(JSTerminal($(QuoteNode(S))))
end
deparse(sym::JSTerminal)::JSString = sym.s

# Convert the nothing symbol into null.
crawl_symbol(::Val{:nothing}) = :(JSTerminal(nothing))
