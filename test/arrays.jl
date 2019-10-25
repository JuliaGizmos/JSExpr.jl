using Test
using JSExpr
using JSExpr: @crawl, deparse, JSTerminal, JSString

@testset "array" begin
        @test @js([1, 2, 3]) == JSString("""[1,2,3]""")
        @test @js((1, 2, 3)) == JSString("""[1,2,3]""")

        my_array = ["foo", "bar"]
        @test @js(console.log($my_array)) == JSString(
                """console.log(["foo","bar"])"""
        )

        @test @js([[], []]) == JSString("""[[],[]]""")
end
