using Test
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal

@testset "arithmetic infix operators" begin
    @testset "addition infix operator" begin
        jsast = @crawl(foo + bar)
        @test jsast.head == :(+)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo + bar"
    end

    @testset "subtraction infix operator" begin
        jsast = @crawl(foo - bar)
        @test jsast.head == :(-)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo - bar"
    end

    @testset "multiplication infix operator" begin
        jsast = @crawl(foo * bar)
        @test jsast.head == :(*)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo * bar"
    end

    @testset "division infix operator" begin
        jsast = @crawl(foo / bar)
        @test jsast.head == :(/)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo / bar"
    end
end

@testset "object infix operators" begin
    @testset "dot infix operator" begin
        jsast = @crawl(foo.bar)
        @test jsast.head == :(.)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo.bar"
    end
end

@testset "assignment infix operators" begin
    @testset "equals infix operator" begin
        jsast = @crawl(foo = bar)
        @test jsast.head == :(=)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo = bar"
    end

    @testset "plus-equals infix operator" begin
        jsast = @crawl(foo += bar)
        @test jsast.head == :(+=)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo += bar"
    end

    @testset "times-equals infix operator" begin
        jsast = @crawl(foo *= bar)
        @test jsast.head == :(*=)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo *= bar"
    end

    @testset "minus-equals infix operator" begin
        jsast = @crawl(foo -= bar)
        @test jsast.head == :(-=)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo -= bar"
    end

    @testset "divide-equals infix operator" begin
        jsast = @crawl(foo /= bar)
        @test jsast.head == :(/=)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:bar)

        jsstr = deparse(jsast)
        @test jsstr == js"foo /= bar"
    end

    @testset "equality infix operator" begin
        @test @js(foo == bar) == JSString("foo == bar")
    end

    @testset "not-equality infix operator" begin
        @test @js(foo != bar) == JSString("foo != bar")
    end
end
