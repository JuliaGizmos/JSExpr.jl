using Test
using JSExpr

@testset "objects" begin
    @testset "braces syntax" begin
        @test string(@js(
            {
                "foo" => "bar",
                "spam" => 1 + 2,
            }
        )) == """{"foo": "bar", "spam": 1 + 2}"""

        @test string(@js(
            {
                :foo => "bar",
                :spam => 1 + 2,
            }
        )) == """{"foo": "bar", "spam": 1 + 2}"""

        @test string(@js(
            {
                foo = "bar",
                "spam" => 1 + 2,
            }
        )) == """{"foo": "bar", "spam": 1 + 2}"""

        @test string(@js(
            { foo }
        )) == """{"foo": foo}"""

        @test string(@js(
            {
                a,
                b = "foo",
                :c => "bar",
            }
        )) == """{"a": a, "b": "foo", "c": "bar"}"""

        @test_throws ErrorException JSExpr.crawl(:({ foo => "bar" }))
        @test_throws ErrorException JSExpr.crawl(:({ "foo" }))
        @test_throws ErrorException JSExpr.crawl(:({ :foo=foo }))
    end

    @testset "namedtuple syntax" begin
        @test string(@js(
            (
                foo="foo",
                bar="bar",
            )
        )) == """{"foo": "foo", "bar": "bar"}"""

        @test_throws ErrorException JSExpr.crawl(:(
            ("foo"=3, foo="bar")
        ))
        @test_throws ErrorException JSExpr.crawl(:(
            (foo="foo", bar)
        ))
    end
end
