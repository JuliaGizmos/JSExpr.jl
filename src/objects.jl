crawl(::Val{:braces}, args...) = _crawl_dict(args...)

function _crawl_dict(args...)
    return :(JSAST(
        :object,
        $(_crawl_objectpair.(args)...)
    ))
end

# Enable `@js { foo }` syntax
function _crawl_objectpair(sym::Symbol)
    return :(
        JSAST(:objectpair, JSTerminal($(string(sym))), $(crawl(sym)))
    )
end

# Enable `@js { foo=foo }` and `@js { :foo => foo }` syntax
function _crawl_objectpair(expr::Expr)
    if expr.head == :call && expr.args[1] == :(=>)
        lhs, rhs = expr.args[2:3]
        # Ensure that the LHS of the pair is a Symbol literal (which will be
        # wrapped in a QuoteNode in the Expr) or a string.
        if lhs isa QuoteNode
            lhs = string(_unquote(lhs))
        elseif lhs isa AbstractString
            lhs = string(lhs)
        else
            lhs_repr = lhs isa Symbol ? "identifier $(lhs)" : string(lhs)
            error(
                "Invalid key expression in object literal syntax " *
                "(LHS of pair expression must be a Symbol or String, " *
                "got $(lhs_repr))."
            )
        end
    elseif expr.head == :(=)
        lhs, rhs = expr.args
        if !(lhs isa Symbol)
            error(
                "Invalid key expression in object literal syntax " *
                "(LHS of equals expression must be a literal identifier, " *
                "got $(lhs))."
            )
        end
        lhs = string(lhs)
    end
    return :(
        JSAST(:objectpair, JSTerminal($(lhs::String)), $(crawl(rhs)))
    )
end

# Disallow things like `@js { "foo" }`
function _crawl_objectpair(expr::Any)
    error(
        "Invalid object literal item " *
        "(expected pair expression, equals expression, or literal identifier)."
    )
end

function deparse(::Val{:object}, pairs...)
    return jsstring(
        "{",
        join(deparse.(pairs), ", "),
        "}",
    )
end#

function deparse(::Val{:objectpair}, key, value)
    return jsstring(
        deparse(key), ": ",
        deparse(value),
    )
end

"""
Determine whether the tuple expression with args `items` is a namedtuple.

This is used when crawling tuples, which is defined in `arrays.jl`.
"""
function _is_namedtuple(items...)
    if isempty(items)
        return false
    end
    firstelt = first(items)
    return firstelt isa Expr && firstelt.head == :(=)
end

function _crawl_namedtuple(items...)
    return :(JSAST(:object, $(_crawl_namedtuple_arg.(items)...)))
end

function _crawl_namedtuple_arg(item)
    if !(item isa Expr && item.head == :(=))
        error("Invalid namedtuple item (expected = expression, got $(item)).")
    end
    lhs, rhs = item.args
    if !(lhs isa Symbol)
        error("Invalid namedtuple key (expected Symbol, got $(lhs)).")
    end
    return :(JSAST(:objectpair, JSTerminal($(string(lhs))), $(crawl(rhs))))
end
