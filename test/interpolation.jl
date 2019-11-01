using Test
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal, JSString

@testset "interpolation" begin
    @testset "interpolation of simple datatypes" begin
        foostr = "foo"
        @test @js(foo = $foostr) == JSString("foo = \"foo\"")

        answer = 42
        @test @js(theAnswer = $answer) == JSString("theAnswer = 42")
    end

    @testset "interpolation of compound datatypes" begin
        options = Dict("foo" => "bar")
        @test @js(options = $options) == JSString("""options = {"foo":"bar"}""")

        numbers = [1, 2, 3, 4]
        @test @js(numbers = $numbers) == JSString("numbers = [1,2,3,4]")
    end

    @testset "interpolation of javascript" begin
        callback = JSString("""() => console.log("done!")""")
        @test @js(callback = $callback) == JSString("callback = $(callback.s)")
    end
end
