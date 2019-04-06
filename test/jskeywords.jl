using Test
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal, JSString

@testset "reserved keywords" begin
    @testset "new keyword without arguments" begin
        jsast = @crawl @new Bar
        @test jsast.head == :new
        @test length(jsast.args) == 1
        @test jsast.args[1] == JSTerminal(:Bar)

        jsstr = deparse(jsast)
        @test jsstr == js"new Bar"
    end

    @testset "new keyword with arguments" begin
        jsstr = @js @new Bar(1, 2, "foo")
        @test jsstr == JSString("new Bar(1, 2, \"foo\")")
    end

    @testset "var keyword" begin
        @test (@js @var foo = bar) == JSString("var foo = bar")
    end

    @testset "const keyword" begin
        @test (@js @const foo = bar) == JSString("const foo = bar")
    end

    @testset "let keyword" begin
        @test (@js @let foo = bar) == JSString("let foo = bar")
    end
end
