# Data Structures

## Objects
Objects are the core data type in JavaScript. There are two way to construct object literals using JSExpr: a special curly-brace syntax and NamedTuple syntax.

### Braces Syntax
Using JSExpr, you can create objects using curly-braces syntax which is loosely adapted from Query.jl. There are three distinct syntaxes for specifying the entries of an object.

Using pair syntax, the left-hand side must be a string literal or a symbol.
```julia
@js @const myObject = {
    :foo => "foo",
    "bar" => "bar",
}
# const myObject = {"foo": "foo", "bar": "bar"}
```

Using equals syntax, the left-hand side must be an identifier (not a symbol or a string).
```julia
@js @const myObject = {
    foo = "foo",
    bar = "bar",
}
# const myObject = {"foo": "foo", "bar": "bar"}
```

Finally, there is a shorthand syntax where a just an identifier is specified.
```julia
@js @const myObject = { foo, bar }
# const myObject = {"foo": foo, "bar": bar}
```

### NamedTuple Syntax
Objects can also be specified as `NamedTuple`'s.
```julia
@js (foo="foo", bar="bar")
# {"foo": "foo", "bar": "bar"}
```

## Arrays
Arrays are specified just as in Julia. Julia tuples are also translated into JavaScript arrays.

```julia
@js [foo, "bar"]
# [foo, "bar"]

@js (foo, "bar")
# [foo, "bar"]
```
