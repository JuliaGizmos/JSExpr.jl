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

        @test string(@js(
            if foo
                foo()
            elseif bar
                bar()
            elseif spam
                spam()
            else
                eggs()
            end
        )) == string(
            "if (foo) { foo(); } elseif (bar) { bar(); } ",
            "elseif (spam) { spam(); } else { eggs(); }"
        )
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

        @test_throws ErrorException JSExpr.crawl(:(
            for i in 1:10, j in i:10
                console.log(i, j)
            end
        ))
    end

end
