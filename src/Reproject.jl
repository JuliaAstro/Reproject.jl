__precompile__()

module Reproject

using FITSIO, WCS

include("parsers.jl")

export 
    parse_input_data,
    parse_output_projection

end # module

