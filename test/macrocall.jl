@testset "macrocall" begin
    @test_throws MethodError JSExpr.crawl(:(
        @foo
    ))
end
