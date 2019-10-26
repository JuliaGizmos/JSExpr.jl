# Special syntactic constructs that need to appear in the JSAST

# Note: Julia's parens disappear at parse time (since they are used to resolve
# parsing ambiguity), so we don't need a corresponding `crawl` method.
deparse(::Val{:parens}, x) = jsstring("(", deparse(x), ")")
