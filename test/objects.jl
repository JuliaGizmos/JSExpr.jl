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

    @testset "object dict with symbol keys" begin
        @test string(@js(
            {
                :foo => "bar",
                :spam => 1 + 2,
            }
        )) == """{["foo"]: "bar",["spam"]: 1 + 2}"""
    end

    @testset "object braces syntax" begin
        @test string(@js(
            {
                "foo" => "bar",
                "spam" => 1 + 2,
            }
        )) == """{["foo"]: "bar",["spam"]: 1 + 2}"""

        @test_throws ErrorException JSExpr.crawl(:({foo}))
        @test_throws ErrorException JSExpr.crawl(:({foo = bar}))
        @test_throws ErrorException JSExpr.crawl(:({foo => "bar", "spam"}))
    end

    @testset "namedtuple syntax" begin
        @test string(@js(
            (
                foo="foo",
                bar="bar",
            )
        )) == """{["foo"]: "foo",["bar"]: "bar"}"""

        @test_throws ErrorException JSExpr.crawl(:(
            ("foo"=3, foo="bar")
        ))
        @test_throws ErrorException JSExpr.crawl(:(
            (foo="foo", bar)
        ))
    end
end
