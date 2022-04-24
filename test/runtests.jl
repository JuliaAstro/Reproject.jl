using Reproject
using Test
using Conda, PyCall
using FITSIO, WCS
using SHA: sha256

Conda.add_channel("astropy")
Conda.add("reproject=0.5")
rp = pyimport("reproject")
astropy = pyimport("astropy")

include("parsers.jl")
include("utils.jl")
include("core.jl")
