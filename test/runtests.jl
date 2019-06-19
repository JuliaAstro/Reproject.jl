using Reproject
using Test
using Conda, PyCall
using FITSIO, WCS

ENV["PYTHON"]=""
Conda.add_channel("astropy")
Conda.add("reproject")
rp = pyimport("reproject")
astropy = pyimport("astropy")

@testset "Reproject.jl" begin
    include("parsers.jl")
    include("utils.jl")
    include("core.jl")
end
