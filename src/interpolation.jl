using JSON
using WebIO: tojs, showjs

function crawl(::Val{:$}, x)
    # sym = gensym()
    # push!(vars, sym => Expr(:call, :tojs, x))
    :(JSTerminal(coercejsstring(tojs($(esc(x))))))
end

"""
    coercejsstring(x)

Coerse a value to a JSString representation.
This is required since `tojs` only returns something that is either a `JSString`
or something that is `JSON.lower`-able, but we just want a `JSString`.
"""
coercejsstring(s::JSString) = s
coercejsstring(s) = JSString(JSON.json(s))
