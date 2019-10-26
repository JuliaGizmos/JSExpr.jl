using Test
using JSExpr

@testset "objects" begin
    @testset "object dict" begin
        @test string(@js(
            Dict(
                "foo" => "bar",
                "spam" => 1 + 2,
            )
        )) == """{["foo"]: "bar",["spam"]: 1 + 2}"""
    end

    @testset "object braces syntax" begin
        @test string(@js(
            {
                "foo" => "bar",
                "spam" => 1 + 2,
            }
        )) == """{["foo"]: "bar",["spam"]: 1 + 2}"""
    end
end
