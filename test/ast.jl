@testset "ast" begin
    @testset "Base.show overload" begin
        ast = JSExpr.@crawl foo = bar
        @test sprint(
            io -> Base.show(io, MIME("text/plain"), ast),
        ) == """JSAST(:(=), JSTerminal(foo), JSTerminal(bar))"""
    end
end
