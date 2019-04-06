using JSExpr
using WebIO
using Test

include("./test-jsexpr2.jl")
include("./infix.jl")
include("./interpolation.jl")
include("./call.jl")
include("./function.jl")
include("./jskeywords.jl")

# if false
# @testset "@js" begin
#     @test @js(nothing) == js"null"
#     @test @js(x) == js"x"
#     @test @js(x.y) == js"x.y"
#
#     x = nothing
#     @test @js($x) == js"null"
#
#     @test @js(begin
#         x
#         y
#     end) == js"x; y"
#
#     #@test @js(x[]) == js"x[]"
#     @test @js(x[1]) == js"x[1]"
#     @test @js(x["a"]) == js"x[\"a\"]"
#     @test @js(x[1,"a"]) == js"x[1,\"a\"]"
#
#
#     @test @js(d(x=1)) == js"{x:1}" # special dict syntax
#     @test @js(d("x\"y"=1)) == JSString("{\"x\\\"y\":1}")
#     @test @js([1, "xyz"]) == js"[1,\"xyz\"]"
#
#     @test @js(1==2) == js"1==2" # special in that it's not wrapped in ()
#
#     @test @js(f()) == js"f()"
#     @test @js(f(x)) == js"f(x)"
#     @test @js(f(x,y)) == js"f(x,y)"
#     @test @js(1+2) == js"(1+2)"
#
#     @test @js(x=1) == js"x=1"
#
#     @test @js(x->x) == js"(function (x){return x})"
#     @test @js(x->begin x
#               return end) == js"(function (x){x; return })"
#     @test @js(x->(1; return x+1)) == js"(function (x){1; return (x+1)})"
#     @test @js(function (x) x+1; end) == js"(function (x){return (x+1)})"
#
#     @test @js(@new F()) == js"new F()"
#     @test @js(@var x=1) == js"var x=1"
#
#     @test @js(if x; y end) == js"x ? (y) : undefined"
#     @test @js(if x; y; else z; end) == js"x ? (y) : (z)"
#     @test @js(if x; y; y+1; else z; end) == js"x ? (y, (y+1)) : (z)"
#     #@test_throws ErrorException @js(if b; @var x=1; x end)
#     # ^ good problem: this now fails in macro expansion time so it's hard to catch!
#
#     @test @js(begin
#         @var acc = 0
#         for i = 1:10
#             acc += 1
#         end
#     end) == js"var acc=0; for(var i = 1; i <= 10; i = i + 1){acc+=1}"
#
#     @test @js(begin
#         @var acc = 0
#         for i = 1:2:10
#             acc += 1
#         end
#     end) == js"var acc=0; for(var i = 1; i <= 10; i = i + 2){acc+=1}"
#
#     @testset "observable interpolation" begin
#         w = Scope("testwidget2")
#         ob = Observable(0)
#         @test_throws ErrorException @js $ob
#
#         ob = Observable{Any}(w, "test", nothing)
#         @test @js($ob) == js"{\"name\":\"test\",\"scope\":\"testwidget2\",\"id\":\"ob_02\",\"type\":\"observable\"}"
#
#         @test @js($ob[]) == js"WebIO.getval({\"name\":\"test\",\"scope\":\"testwidget2\",\"id\":\"ob_02\",\"type\":\"observable\"})"
#         @test @js($ob[] = 1) == js"WebIO.setval({\"name\":\"test\",\"scope\":\"testwidget2\",\"id\":\"ob_02\",\"type\":\"observable\"},1)"
#     end
# end
# end
