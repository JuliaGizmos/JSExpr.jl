function crawl(::Val{:ref}, args...)
    return :(dereference($(crawl.(args)...)))
end
function deparse(::Val{:index}, b::JSNode, idx)::JSString
    return jsstring(deparse(b), "[", deparse(idx), "]")
end

"""
Generate a JSNode should be inserted when a value is dereferences.

This function is called with the value that is to be dereferenced and not the
expression itself that is being dereferenced (i.e., after the crawl phase).

This is used mainly to allow WebIO to customize behavior when dereferencing
Observables.
"""
function dereference(args...)
    return JSAST(:index, args...)
end
