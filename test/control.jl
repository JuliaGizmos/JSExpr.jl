using Test
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal, JSString

@testset "control expressions" begin

    @testset "if expressions" begin
        @test @js(
            if foo
                bar()
            end
        ) == JSString("if (foo) { bar(); }")

        @test @js(
            if foo
                bar()
            else
                spam()
            end
        ) == JSString("if (foo) { bar(); } else { spam(); }")
    end

end
