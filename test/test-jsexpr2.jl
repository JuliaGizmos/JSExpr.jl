using Test
using WebIO
using WebIO: JSString
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal, JSAST

# myjs = @js foo = nothing
# @test myjs.s == "foo = null"

@testset "parsing of special symbols" begin
    @testset "parsing of nothing" begin
        jsast = @crawl(foo = nothing)
        @test jsast.head == :(=)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:null)

        jsstr = deparse(jsast)
        @test jsstr == js"foo = null"
    end

    @testset "parsing of booleans" begin
        jsast = @crawl(foo = true)
        @test jsast.head == :(=)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(Symbol(:true))

        jsstr = deparse(jsast)
        @test jsstr == js"foo = true"

        jsast = @crawl(foo = false)
        @test jsast.head == :(=)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(Symbol(:false))

        jsstr = deparse(jsast)
        @test jsstr == js"foo = false"
    end
end

@testset "parsing of numbers" begin
    jsast = @crawl(foo = 123)
    @test jsast.head == :(=)
    @test length(jsast.args) == 2
    @test jsast.args[1] == JSTerminal(:foo)
    @test jsast.args[2] == JSTerminal(123)

    jsstr = deparse(jsast)
    @test jsstr == js"foo = 123"
end

@testset "parsing of strings" begin
    jsast = @crawl(foo = "foo")
    @test jsast.head == :(=)
    @test length(jsast.args) == 2
    @test jsast.args[1] == JSTerminal(:foo)
    @test jsast.args[2] == JSTerminal(js"\"foo\"")

    jsstr = deparse(jsast)
    @test jsstr == js"foo = \"foo\""
end
