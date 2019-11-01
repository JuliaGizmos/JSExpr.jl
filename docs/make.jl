using Documenter
using JSExpr

makedocs(
    sitename="JSExpr.jl",
    authors="Travis DePrato and contributors",
    pages=[
        "index.md",
        "basics.md",
        "datastructures.md",
        "juliaisms.md",
        "api.md",
    ],
)

deploydocs(
    repo="github.com/JuliaGizmos/JSExpr.jl.git",
)
