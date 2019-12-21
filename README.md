# JSExpr

| Build | Coverage |
|-------|----------|
| [![Build Status](https://travis-ci.org/JuliaGizmos/JSExpr.jl.svg?branch=master)](https://travis-ci.org/JuliaGizmos/JSExpr.jl) | [![codecov](https://codecov.io/gh/JuliaGizmos/JSExpr.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaGizmos/JSExpr.jl)

This package provides two macros that are used to write JavaScript code inside
of Julia programs.
* The `@js` macro translates Julia syntax to the equivalent JavaScript
* The `@js"..."` macro is used to write code using string literals with _smart_
  interpolation of values from Julia

## Examples

```julia
julia> using JSExpr

julia> @js document.querySelector("#root")
JSString("document.querySelector(\"#root\")")

julia> @js (a, b) -> a + b
JSString("(a, b) => { return a + b; }")

julia> config = Dict("foo" => "bar");
julia> js"initializeProgram($config);"
JSString("initializeProgram({\"foo\":\"bar\"});")
```

## Interpolation

You can interpolate Julia objects or `JSString`s (e.g. from other `@js` or
  `js"..."` invocations) as well as values from Julia (such as normal
  strings, `Dict`s, etc.).

```julia
julia> foo = 42;
julia> callback = @js a -> a + $foo
JSString("(a) => { return a + 42; }")

julia> f = @js array -> array.map($callback)
JSString("(array) => { return array.map((a) => { return a + 42; }); }")
```

#### Custom Interpolation
By default, values are serialized using the `JSON` package.
This makes sense for `Dict`s, `Array`s, and most other "primitive" types.

3rd-party packages can customize serialization of their own types by defining
a method for `JSExpr.interpolate`.
The return value of `JSExpr.interpolate` should be a `JSNode`.

```julia
julia> struct Link; text::String; href::String; end;
julia> JSExpr.interpolate(link::Link) = JSExpr.JSTerminal(js"<a href=$(link.href)>$(link.text)</a>");
julia> @js @const link = $(Link("Julia", "https://julialang.org/"))
JSString("const link = <a href=\"https://julialang.org/\">\"Julia\"</a>")
```

## Object Literals

Objects are ubiquitous in JavaScript.
To create objects using JSExpr, you can use a simple syntax using braces.
There are two variants of this syntax (_NamedTuple_ style and _Pair_ style).
You can also create objects use normal `NamedTuple` syntax.

```julia
# NamedTuple braces style
julia> @js { foo="foo", bar="bar" }
JSString("{\"foo\": \"foo\", \"bar\": \"bar\"}")

# Pair braces style (similar to Dict constructor)
julia> @js { :foo => "foo", :bar => "bar" }
JSString("{\"foo\": \"foo\", \"bar\": \"bar\"}")

# NamedTuple syntax
julia> @js (foo="foo", bar="bar")
JSString("{\"foo\": \"foo\", \"bar\": \"bar\"}")
```

#### Why not `Dict`?
JSExpr does not attempt to translate _semantics_ between Julia and JavaScript
  (with a few very minor exceptions covered in _Juliaisms_ below).
Since `Dict` can be a valid function name in JavaScript, we do not translate
  the Julia `Dict` constructor to an object creation syntax.

## Juliaisms
JSExpr, for the most part, does not attempt to translate semantics between
  Julia and the resulting JavaScript code.
The reason for the decision is that Julia and JavaScript are
  wildly different languages and we would invariably mess up some edge cases.
We do, however, translate a few Julian constructs to a _semantically_ equivalent
  JavaScript.

#### Range Syntax (`...:...`)
JavaScript doesn't have a native `Range` object and the typical way to repeat a
loop body `n` times is to use a C-style `for` loop. There is no syntax for this
style of for loop in Julia, and `:` is not a valid JavaScript identifier, so the
colon function (`:`) is translated to JavaScript code that acts like a `Range`
object in Julia.

```julia
julia> @js for i in 1:10
         console.log(i)
       end
JSString("for (let i of (new Array(10).fill(undefined).map((_, i) => i + 1))) { console.log(i); }")
```

The resulting JS is very ugly and will fully materialize the range and so
should only be used for relatively small ranges.

## Serialization

Serializing a `JSString` to JSON will result in a normal string containing the
JavaScript code.

```julia
julia> f = @js array -> array.map($callback);
julia> JSON.print(Dict("foo" => "bar", "bar"=>f))
{"bar":"(array) => { return array.map((a) => { return a + 42; }); }","foo":"bar"}
```

## Supported Expressions
- Function calls
- Comparison operators
- Object and array literals
- Function creation (named and anonymous functions)
- If statements
- For and while loops
- JavaScript keywords (`@new`, `@var`, `@let`, `@const`)

## Unsupported Expressions
### Not Yet Supported
* Ternary expressions (`... ? ... : ...`)
* `try` / `catch`

### Might Never Be Supported
* Object destructuring
* Argument splatting

If you notice anything else that's not supported or doesn't work as intended,
please [open an issue](https://github.com/JuliaGizmos/JSExpr.jl/issues).

#### Ternary Expressions
Julia lowers (during parse) `if` statements and ternary expressions (`... ? ... : ...`)
to the same `Expr`, so JSExpr cannot distinguish between the two.
This poses an issue because JavaScript does not allow non-expression statements
(e.g., loops and variable declarations) inside of a ternary expression, but if
statements cannot be used in contexts which expect a value (but they _can_ be
used in such contexts in Julia).

There are plans to implement a heuristic to emit a ternary expression if
  appropriate (e.g., if the bodies of the ternary expression contains only one
  sub-expression) but this is not implemented yet.
