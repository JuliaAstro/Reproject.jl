using Documenter
using Reproject

makedocs(;
    sitename = "Reproject.jl",
    modules = [Reproject],
    authors = "Mosè Giordano, Rohit Kumar",
    format = Documenter.HTML(),
    pages = [
        "index.md",
        "api-reference.md",
    ],
)

deploydocs(;
    repo = "github.com/JuliaAstro/Reproject.jl.git",
    push_preview = true
)
