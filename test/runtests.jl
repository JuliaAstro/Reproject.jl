using Reproject
using Test
using PythonCall
using FITSFiles, FITSWCS
using Pkg.Artifacts: ensure_artifact_installed

rp = pyimport("reproject")
astropy = pyimport("astropy")

include("parsers.jl")
include("utils.jl")
include("core.jl")
include("aqua.jl")
include("doctest.jl")
