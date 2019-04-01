# "Fundamental" literals
crawl(ex::String) = JSSymbol(js"$ex")
crawl(b::Bool) = crawl(Symbol(b))

# Symbols
# We sub-dispatch on symbols to allow for special handling of certain keywords.
function crawl(sym::Symbol)
    if hasmethod(crawl, (Val{:symbol}, Val{sym}))
        return crawl(Val(:symbol), Val(sym))
    end
    return JSSymbol(sym)
end
deparse(sym::JSSymbol)::JSString = sym.s

# Convert the nothing symbol into null.
crawl(::Val{:symbol}, ::Val{:nothing}) = JSSymbol(:null)
