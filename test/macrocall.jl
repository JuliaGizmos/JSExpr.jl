@testset "macrocall" begin
    @testset "@js interpolates @js_str" begin
        @test string(@js foo = js"bar") == "foo = bar"
        @test string(@js foo = js"\$"(".my-class")) == "foo = \$(\".my-class\")"
    end

    @testset "unknown macros throw errors" begin
        @test_throws MethodError JSExpr.crawl(:(
            @foo
        ))
    end
end
