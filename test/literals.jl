using Test
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal, JSAST

# myjs = @js foo = nothing
# @test myjs.s == "foo = null"

@testset "special symbols" begin
    @testset "nothing" begin
        jsast = @crawl(foo = nothing)
        @test jsast.head == :(=)
        @test length(jsast.args) == 2
        @test jsast.args[1] == JSTerminal(:foo)
        @test jsast.args[2] == JSTerminal(:null)

        jsstr = deparse(jsast)
        @test jsstr == js"foo = null"
    end

    @testset "booleans" begin
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

@testset "number literals" begin
    jsast = @crawl(foo = 123)
    @test jsast.head == :(=)
    @test length(jsast.args) == 2
    @test jsast.args[1] == JSTerminal(:foo)
    @test jsast.args[2] == JSTerminal(123)

    jsstr = deparse(jsast)
    @test jsstr == js"foo = 123"
end

@testset "string literals" begin
    jsast = @crawl(foo = "foo")
    @test jsast.head == :(=)
    @test length(jsast.args) == 2
    @test jsast.args[1] == JSTerminal(:foo)
    @test jsast.args[2] == JSTerminal(js"\"foo\"")

    jsstr = deparse(jsast)
    @test jsstr == js"foo = \"foo\""

    @test string(@js """foo is "fantastic"!""") == "\"foo is \\\"fantastic\\\"!\""
end
