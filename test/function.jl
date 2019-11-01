using Test
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal, JSString

@testset "function" begin

    @testset "function keyword" begin
        @test string(@js function add(x, y)
            return x + y
        end) == "function add(x, y) { return x + y; }"

        @test string(@js function log(message)
            console.log(message)
        end) == "function log(message) { console.log(message); }"

        @test string(@js function foo() end) == "function foo() {}"
        @test string(@js function () end) == "(function () {})"
    end

    @testset "anonymous function-keyword function" begin
        @test string(@js(
            function (x, y) console.log(x + y) end
        )) == "(function (x, y) { console.log(x + y); })"
    end

    @testset "anonymous arrow function" begin
        jsstr = @js x -> x + 3
        @test jsstr == JSString("(x) => { return x + 3; }")

        jsstr = @js (x, y) -> x + y
        @test jsstr == JSString("(x, y) => { return x + y; }")
    end

    @testset "automatic return insertion" begin
        @test string(@js(
            (x, y) -> if x > y
                x
            else
                y
            end
        )) == "(x, y) => { if (x > y) { return x; } else { return y; }; }"
    end
end
