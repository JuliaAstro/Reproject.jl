"""
Parse input data and returns an Array and WCS object.
"""
function parse_input_data(input_data::ImageHDU)
    return read(input_data), WCS.from_header(read_header(input_data, String))[1]
end

function parse_input_data(input_data::String, hdu_in = nothing)
    return parse_input_data(FITS(input_data), hdu_in = hdu_in)
end

function parse_input_data(input_data::FITS, hdu_in = nothing)
   if hdu_in == nothing
        if length(input_data) > 1
            throw(ArgumentError("More than one HDU is present, please specify HDU to use with ``hdu_in=`` option"))
        else
            hdu_in = 1
        end
    end
    return parse_input_data(input_data[hdu_in])
end

function parse_input_data(input_data, hdu_in = nothing)
    throw(TypeError(input_data, "should be in ", Union{String, FITS, ImageHDU, Tuple{ImageHDU,FITSHeader}}))
end

# TODO: extend support for passing FITSHeader when FITSHeader to WCSTransform support is possible.


"""
Parse output projection and returns a WCS object and Shape of output
"""
function parse_output_projection(output_projection::WCSTransform, shape_out = nothing)
    wcs_out = output_projection
    if shape_out isa nothing
        throw(ArgumentError("Need to specify shape when specifying output_projection as WCS object"))
    elseif length(shape_out) == 0
        throw(DomainError(shape_out, "The shape of the output image should not be an empty tuple"))
    end

    return wcs_out, shape_out
end

function parse_output_projection(output_projection::ImageHDU, shape_out = nothing)
    wcs_out = WCS.from_header(read_header(output_projection))[1]
    if shape_out == nothing
        shape_out = size(output_projection)
    end
    if length(shape_out) == 0
        throw(DomainError(shape_out, "The shape of the output image should not be an empty tuple"))
    end
    return wcs_out, shape_out
end

function parse_output_projection(output_projection::String, hdu_number = nothing)
    hdu_list = FITS(output_projection)
    if hdu_number == nothing
        wcs_out = WCS.from_header(read_header(hdu_list[1], String))
    else
        wcs_out = WCS.from_header(read_header(hdu_list[hdu_number], String))
    end
    
    try
        shape_out = size(output_projection)
    catch
        throw(ArgumentError("Given FITS file doesn't have ImageHDU"))
    end
    
    return wcs_out, shape_out
end

function parse_output_projection(output_projection, shape_out = nothing)
    throw(TypeError(output_projection, "should be in ", Union{String, WCSTransform, FITSHeader}))
end