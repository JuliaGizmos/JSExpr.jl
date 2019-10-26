using JSON
using WebIO: tojs

function crawl(::Val{:$}, x)
    return :(interpolate($(esc(x))))
end

"""
Determine what JSNode should be inserted when a value is interpolated.

This function is called with the value that is to be interpolated and not the
expression itself that is being interpolated (i.e., after the crawl phase).
"""
function interpolate(x)
    return JSTerminal(_tojsstring(tojs(x)))
end

"""
    _tojsstring(x)

Coerse a value to a JSString representation.
This is required since `tojs` only returns something that is either a `JSString`
or something that is `JSON.lower`-able, but we just want a `JSString`.
"""
_tojsstring(s::JSString) = s
_tojsstring(s) = JSString(JSON.json(s))
