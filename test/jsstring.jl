@testset "@js_str macro" begin
    @testset "@js_str character escaping" begin
        @test js"\"foo\"" == JSString("\"foo\"")
        @test js"\"foo\"" == JSString("\"foo\"")
        @test js"this.\$refs" == JSString(raw"this.$refs")

        @test js"foo\$" == JSString(raw"foo$")
        @test js"\$('div.my-id')" == JSString(raw"$('div.my-id')")

        @test js"'foo\\bar'" == JSString("'foo\\bar'")

        foo = "foo"
        @test js"\\$foo" == JSString("\\\"foo\"")

        # See note about Julia and weirdness with escaping when quotes are involved.
        @test js"""console.log("\\")""" == JSString("""console.log(\"\\\")""")
        #@test js"""console.log(\"\\\")""" == JSString("""console.log(\"\\\")""")
        @test js"""foo = '\\\\'""" == JSString(raw"""foo = '\\'""")
    end

    @testset "@js_str interpolation" begin
        mystr = "foo"
        @test js"const foo = $mystr" == JSString("const foo = \"foo\"")
        @test js"const foo = $(mystr)" == JSString("const foo = \"foo\"")

        mydict = Dict(:foo => "bar")
        @test js"const myDict = $mydict" == JSString("""const myDict = {"foo":"bar"}""")
    end

    @testset "@js_str interpolation overloading" begin
        person_struct_name = gensym()
        @eval begin
            struct $(person_struct_name)
                name::String
                age::Int
            end
            JSExpr.tojs(person::$(person_struct_name)) = "$(person.name)/$(person.age)"
        end
        Person = @eval $(person_struct_name)
        travis = Person("Travis", 22)

        @test js"const travis = $travis" == JSString("const travis = \"Travis/22\"")
    end

    @testset "JSString interpolation into normal strings" begin
        myjs = js"""console.log("foo");"""
        @test "<script>$(myjs)</script>" == """<script>console.log("foo");</script>"""
    end
end
