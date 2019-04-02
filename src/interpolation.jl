using WebIO: tojs

function crawl(::Val{:$}, x)
    # sym = gensym()
    # push!(vars, sym => Expr(:call, :tojs, x))
    :(JSTerminal(tojs($(esc(x)))))
end
