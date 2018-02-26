# many string or interpolated expression fragments
struct F
    xs
end

function intersperse(xs, delim)
    ys = []
    isempty(xs) && return ys

    push!(ys, first(xs))
    for y in xs[2:end]
        push!(ys, delim)
        push!(ys, y)
    end
    ys
end
_flatten(x) = [x]
function _flatten(x::F)
    parts = []
    for x in x.xs
        if x isa F
            append!(parts, _flatten(x))
        else
            push!(parts, x)
        end
    end
    parts
end

# concatenate contiguous fragments of strings
function _simplify(xs, i=1, acc=[])
    if isempty(xs) || i > length(xs)
        return acc
    end
    while i <= length(xs) && xs[i] isa Expr
        push!(acc, xs[i])
        i+=1
    end
    i0 = i
    while i <= length(xs) && xs[i] isa String
        i+=1
    end
    if i0 <= length(xs) && i0 <= i
        push!(acc, join(xs[i0:i-1]))
    end
    _simplify(xs, i, acc)
end
