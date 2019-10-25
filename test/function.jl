using Test
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal, JSString

@testset "function" begin

    @testset "function with explicit return" begin
        jsstr = @js function add(x, y)
            return x + y
        end

        @test jsstr == JSString("function add(x, y) { return x + y; }")
    end

    @testset "function with implicit return" begin
        jsstr = @js function add(x, y)
            x + y
        end

        @test jsstr == JSString("function add(x, y) { return x + y; }")
    end

    @testset "anonymous arrow function" begin
        jsstr = @js x -> x + 3
        @test jsstr == JSString("(x) => { return x + 3; }")

        jsstr = @js (x, y) -> x + y
        @test jsstr == JSString("(x, y) => { return x + y; }")
    end
end
