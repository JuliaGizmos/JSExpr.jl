# Note: macros have to be defined at global scope
macro _jsshow_macrocall_test(ex)
    strrepr = string(ex)
    return :(@js((function (arg)
        console.log($strrepr + " = " + arg); return arg
    end)($(ex))))
end

@testset "macrocall" begin
    @test string(@js(foo = @_jsshow_macrocall_test 1 + 3)) ==
        """foo = (function (arg) { console.log("1 + 3" + " = " + arg); return arg; })(1 + 3)"""

    @test string(@js js"\$"("#my-id")) == raw"""$("#my-id")"""
end
