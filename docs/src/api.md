# Internal API

!!! note

    Generally, end-users only need to use the `@js` and `js"..."` macros (the public API, which is `export`ed).

    All other non-underscore-prefixed functions are considered internal API (_i.e._, API that should not be used by end-users).
    These methods can be extended by packages (such as [WebIO.jl](https://github.com/JuliaGizmos/WebIO.jl)) to provide additional functionality. Breaking changes in internal API functionality may occur between minor versions.

    Underscore-prefixed functions are considered private API and should not be used or extended and may be modified or removed between patch versions.

## Overview
JSExpr works in two phases.

The first phase is the [`crawl`](@ref JSExpr.crawl) phase.
During this phase, the Julia input expression is recursively converted to an equivalent [`JSAST`](@ref JSExpr.JSAST).
Technically, the crawl phase produces a Julia expression that, when evaluated, produces the desired [`JSAST`](@ref JSExpr.JSAST) (the reason for this is so that we can support interpolation).

The second phase is the [`deparse`](@ref JSExpr.deparse) phase which recursively transforms a [`JSAST`](@ref JSExpr.JSAST) into a `JSString`.

## Abstract Syntax Tree
```@docs
JSExpr.JSNode
JSExpr.JSTerminal
JSExpr.JSAST
```

## Crawl Phase
The crawl phase works using dispatch on `Val` types.
For example, translating `if` statements is implemented using the `crawl(::Val{:if}, args...)` method. Additionally, [`crawl_call`](@ref JSExpr.crawl_call) and [`crawl_macrocall`](JSExpr.crawl_macrocall) are defined similarly but are used to define special handling when invoking certain functions, such as `:` (the `Range` constructor), and macros (such as `@const`).
```@docs
JSExpr.crawl
JSExpr.crawl_call
JSExpr.crawl_macrocall
```

## Deparse Phase
The deparse phase works similarly to the [`crawl`](@ref JSExpr.crawl) phase and is also implemented using dispatch on `Val` types.
```@docs
JSExpr.deparse
```
