export @var, @new

# Unfortunately there's no good way to deprecate these macros in a way that
# actually yields warnings since they're now parsed during the `crawl` process
# and are never a actually invoked during normal usage.
macro var(x)
    Base.depwarn("Importing @var from JSExpr.jl is deprecated.", :jsexpr_var_deprecation)
    esc(x)
end
macro new(x)
    Base.depwarn("Importing @new from JSExpr.jl is deprecated.", :jsexpr_new_deprecation)
    esc(x)
end
