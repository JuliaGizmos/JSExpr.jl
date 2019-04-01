# Allow override-able parsing of calls
function crawl(h::Val{:call}, m::Symbol, b...)::JSNode

    # Check for overrides
    if hasmethod(crawl, typeof((Val(:call), Val(m), b...)))
        return crawl(Val(:call), Val(m), b...)::JSNode

    # Otherwise pass as a call
    else
        return JSAST(:call, [crawl(m), crawl.(b)...])
    end
end
