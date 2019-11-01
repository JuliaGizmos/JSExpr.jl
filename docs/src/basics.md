# Basics

Most simple Julia constructs are translated to equivalent JavaScript naturally.

```julia
@js 1 + 2
# 1 + 2

@js foo(bar)
# foo(bar)
```

## Functions
Functions definitions behave mostly as expected.
There are a few things to note.

* Functions defined using the `function` keyword do not automatically return the value of their last expression.
* Using `this` differs between functions declared with the `function` keyword and arrow functions (see the note below).

!!! note

    JavaScript has two types of functions: those declared with the `function` keyword and arrow functions; the difference between the two types lies in how JavaScript handles `this`.
    The details are a bit hairy and are discussed in depth [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/this).

    Since JSExpr doesn't attempt to translate semantics between Julia (which doesn't even have a `this` keyword), it's important to be wary of the distinction if you write code that uses `this`.

#### Examples
Defining "normal" functions is the same as in Julia.
```julia
@js function square(arg)
    return arg * arg
end
# function square(arg) { return arg * arg; }
```

JavaScript also makes heavy use of anonymous functions, which can be declared using either the `function` keyword or using an arrow function.
```julia
@js @const square = function (arg)
    return arg * arg
end
# const square = (function (arg) { return arg * arg; })

@js @const square = (arg) -> arg * arg
# const square = (arg) => { return arg * arg; }
```

## Control Flow
JSExpr supports the normal control flow statements, such as `if` statements and `for` and `while` loops.

```julia
@js if foo
    console.log("foo!")
else
    console.log("not foo!")
end
# if (foo) { console.log("foo!"); } else { console.log("not foo!"); }
```

```julia
@js for elt in myArray
    console.log(elt)
end
# for (let elt of myArray) { console.log(elt); }
```

```julia
@js while true
    alert("Popup!")
end
# while (true) { alert("Popup!"); }
```

## Interpolation
Julia values can be interpolated into the JavaScript that is generated by JSExpr. It's important to note that this interpolation is static (_i.e._, when used in JavaScript, the interpolated value will be what it was at interpolation time).

```julia
config = Dict(:foo => "bar")
@js myService.initialize($config)
# myService.initialize({"foo":"bar"})
```