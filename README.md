# JSExpr

This package provides the `@js` macro which translates a Julia expression to JavaScript.

## Example

```julia
julia> using JSExpr

julia> @js document.querySelector("#root")
WebIO.JSString("document.querySelector(\"#root\")")

julia> @js (a,b) -> a+b
WebIO.JSString("(function (a,b){return (a+b)})")
```

The `JSString` object wraps a Julia string. You can access the plain string from the `.s` field.

## Interpolation

You can interpolate Julia objects or `JSString` expressions (i.e. result of `@js` macro invocations) in a `@js` macro.

```julia
julia> foo = 42
42

julia> callback = @js a -> a + $foo
WebIO.JSString("(function (a){return (a+42)})")

julia> f = @js array -> array.map($callback)
WebIO.JSString("(function (array){return array.map((function (a){return (a+42)}))})")
```

JSON encoding a `JSString` or an object containing it serializes it as a string.

```julia
julia> JSON.print(Dict("foo" => "bar", "bar"=>f))
{"bar":"(function (array){return array.map((function (a){return (a+42)}))})","foo":"bar"}
```
This is not ideal when you want to use the serialized output as JavaScript, for example in a `<script>` tag. In this case, you should use `JSExpr.jsexpr`

```julia
julia> JSExpr.jsexpr(Dict("foo" => "bar", "bar"=>f))
WebIO.JSString("{\"bar\":(function (array){return array.map((function (a){return (a+42)}))}),\"foo\":\"bar\"}")
```

## Object literals

The `@js` equivalent of

```js
{foo: 42, bar: "baz"}
```

is

```js
julia> @js d(foo=42, bar="baz")
WebIO.JSString("{foo:42,bar:\"baz\"}")
```

or a `Dict`

```
julia> @js Dict(:foo=>42, :bar=>"baz")
WebIO.JSString("{foo:42,bar:\"baz\"}")
```

## Supported expressions

- Function call
- Comparison operators
- Dictionary / object literal
- Anonymous functions (automatically return the result)
- Function expressions (ditto)
- Assignment, `=` and `+=`, `-=`, `*=`, `&=`, `|=`
- If statements (`@var` expressions are not allowed in `if` statements yet). Note: `if` expressions are lowered to the ternary operator and hence return a value - this allows them to be used as the last expression in a function.
- Array indexing
- `for` expression on range literals (i.e. `for x in a:b` or `for x in a:s:b`)
- `return` statements
- `@new Foo()` as the equivalent of `new Foo()` in JS
- `@var foo = bar` as the equivalent of `var foo = bar` in JS
