using Test
using JSExpr

@testset "juliaisms" begin
    @testset "range expression" begin
        expr_str = string(@js(
            for i in 2:11
                console.log(i)
            end
        ))
        @test occursin("new Array(10)", expr_str)
        @test occursin("console.log(i);", expr_str)

        @test_throws ErrorException JSExpr.crawl(:(1.5:3.5))
        @test_throws ErrorException JSExpr.crawl(:(1:2:10))
    end
end
