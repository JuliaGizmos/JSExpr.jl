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

    @testset "while expressions" begin
        @test @js(
            while true
                foo()
            end
        ) == JSString("while (true) { foo(); }")

        @test @js(
            while foo
                if (bar)
                    continue
                end
                break
            end
        ) == JSString("while (foo) { if (bar) { continue; }; break; }");
    end

    @testset "for expressions" begin
        @test @js(
            for i in myiterable
                console.log(i)
            end
        ) == JSString("for (let i of myiterable) { console.log(i); }")
    end

end
