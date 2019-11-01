using JSExpr
using WebIO: WebIO
using JSExpr: @js_str
import WebIO: scopeid
using Test

include("./jsstring.jl")
include("./ast.jl")
include("./literals.jl")
include("./infix.jl")
include("./interpolation.jl")
include("./call.jl")
include("./macrocall.jl")
include("./function.jl")
include("./jskeywords.jl")
include("./arrays.jl")
include("./objects.jl")
include("./control.jl")
include("./juliaisms.jl")

include("./webio.jl")
