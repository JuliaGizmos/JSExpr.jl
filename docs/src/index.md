# JSExpr.jl

JSExpr is a simple library that's lets you write JavaScript using convenient and familiar JavaScript syntax.

!!! note

    JSExpr attempts to translate Julia _syntax_ into (more-or-less) equivalent JavaScript _syntax_. Importantly, **JSExpr does not translate semantics between Julia and JavaScript**. This means that your `println` calls will not be translated into equivalent `console.log` statements.

    There are a few exceptions to this rule. See [Juliaisms](@ref) for more information about those exceptions.

## Interactivity
This package does **not** provide any interactivity between Julia and JavaScript. For that, check out [WebIO.jl](https://github.com/JuliaGizmos/WebIO.jl).

## What about WebAssembly?
As mentioned above, JSExpr does not translate semantics between Julia and the generated JavaScript code, whereas WebAssembly will result in WASM bytecode that has the same semantics as the input Julia program. As of late 2019, Julia has quite a ways to go before being a full-fledged citizen in the browser world.

It is worth noting that [WebAssembly is not trying to replace JavaScript](https://webassembly.org/docs/faq/#is-webassembly-trying-to-replace-javascript).
WebAssembly is designed to handle the high-performance, usually algorithmic, components of modern web applications (such as visualization, graphing, video processing, compression, etc.).
