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

        @testset "array indexing" begin
            @test @js([1, 2, 3][0]) == JSString("[1,2,3][0]")
        end

        @testset "tuple unpacking" begin
            @test @js(
                for (key, value) in Object.entries(myObj)
                    console.log(key, value)
                end
            ) == js"""for (let [key,value] of Object.entries(myObj)) { console.log(key, value); }"""
        end
end
