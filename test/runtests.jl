using JSExpr
using WebIO
import WebIO: scopeid
using Test

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
