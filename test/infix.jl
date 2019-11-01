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

    @testset "string concatenation infix operator" begin
        @test string(@js(key + " => " + value)) == "key + \" => \" + value"
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

    @testset "associativity of infix operators" begin
        @test string(@js(5 * (1 + 2))) == "5 * (1 + 2)"
    end
end

@testset "unary infix operators" begin
    @test @js(-123) == js"-123"
    @test @js(-foo) == js"-foo"
    @test @js(+@new Date) == js"+new Date"
    @test @js(-foo + bar) == js"-foo + bar"
    @test @js(-(foo + bar)) == js"-(foo + bar)"
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

@testset "logical infix operators" begin
    @testset "&&" begin
        @test string(@js foo && bar) == "foo && bar"
        @test string(@js foo && bar && spam) == "foo && bar && spam"
    end

    @testset "logical infix associativity" begin
        @test string(@js foo && (bar || spam)) == "foo && (bar || spam)"
    end

    @testset "parenthesization" begin
        @test string(@js foo && bar()) == "foo && bar()"
        @test string(@js (foo && bar()) || spam()) == "(foo && bar()) || spam()"
    end
end
