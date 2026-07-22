using Reproject
using Test
using PythonCall
using FITSIO, WCS
using SHA: sha256
using Downloads: download

rp = pyimport("reproject")
astropy = pyimport("astropy")

include("parsers.jl")
include("utils.jl")
include("core.jl")
include("aqua.jl")
include("doctest.jl")
