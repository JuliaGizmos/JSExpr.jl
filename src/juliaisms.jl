# Transform a range expression (e.g., `1:10`) into a (more-or-less) equivalent
# construct in JavaScript.
# NOTE: We could also do this be converting a range into an array and including
# that array verbatim in the JS code, but that's not legible if there are a
# significant number of elements in the array (e.g., it's not desirable to
# include an array literal with 100 elements in it in the generated JS code).
function crawl_call(::Val{:(:)}, start::Integer, stop::Integer)
    # Because JavaScript arrays are terrible, we have to fill the array with
    # undefined (otherwise it can't be iterated over) after we construct it with
    # the length specified in the constructor.
    return :(JSTerminal(jsstring($((
        "(",
        "new Array($(stop - start + 1))",
        ".fill(undefined)",
        ".map((_, i) => i + $start)",
        ")",
    )...))))
end

function crawl_call(::Val{:(:)}, args...)
    error("Range syntax cannot be parsed by JSExpr.")
end
