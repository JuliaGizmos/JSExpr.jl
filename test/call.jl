using Test
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal, JSString

@testset "call" begin
    @testset "call builtin functions" begin
        @test @js(console.log("foo")) == JSString("""console.log("foo")""")
    end
end
