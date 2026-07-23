using Documenter
using DocumenterInterLinks
using Reproject
using Documenter.Remotes: GitHub

links = InterLinks(
    "AstroImages" => "https://juliaastro.org/AstroImages/stable/",
    "FITSFiles" => "https://juliaastro.org/FITSFiles/stable/",
)

makedocs(;
    sitename = "Reproject.jl",
    modules = [Reproject],
    authors = "Mosè Giordano, Rohit Kumar",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://juliaastro.org/Reproject/stable/",
    ),
    pages = [
        "index.md",
        "api-reference.md",
    ],
    repo = GitHub("JuliaAstro/Reproject.jl"),
    # Doctests are run as part of the test suite instead (test/doctest.jl)
    doctest   = false,
    plugins   = [links],
)

deploydocs(;
    repo = "github.com/JuliaAstro/Reproject.jl.git",
    push_preview = true,
    versions = ["stable" => "v^", "v#.#"], # Restrict to minor releases
)
