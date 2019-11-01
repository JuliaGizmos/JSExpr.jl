# Juliaisms

While JSExpr does not usually make an effort to translate semantics between Julia and JavaScript, there are a few exceptions. These exceptions are generally only made if there is no way that the syntax could conflict with JavaScript syntax (_e.g._, `Dict` and `println` are valid identifiers in JavaScript, so we don't translate these to an object constructor and `console.log` respectively).

## Ranges
Julia is rather restrictive about what can appear as an iteration specification in a for loop. This makes it impossible to write C-style for loops (such as `for (let i = 0; i < n; i += 1)`).

Since JavaScript doesn't have a native range type, and `:` is not a valid identifier in JavaScript, JSExpr does translate range expressions that use the `:` syntax. The resulting JavaScript is ugly and will materialize the entire range.

```julia
@js for i in 1:10
    console.log(i)
end
# for (let i of (new Array(10).fill(undefined).map((_, i) => i + 1))) { console.log(i); }
```
