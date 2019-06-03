"""
    parse_input_data(input_data::ImageHDU)
    parse_input_data(input_data::String; hdu_in = nothing)
    parse_input_data(input_data::FITS; hdu_in = nothing)

Parse input data and returns an Array and WCS object.

# Arguments
- `input_data`: image to reproject which can be name of a FITS file,
                an ImageHDU or a FITS file. 
- `hdu_in`: used to set HDU to use when more than one HDU is present. 
"""
function parse_input_data(input_data::ImageHDU)
    return read(input_data), WCS.from_header(read_header(input_data, String))[1]
end

function parse_input_data(input_data::String; hdu_in = nothing)
    return parse_input_data(FITS(input_data), hdu_in = hdu_in)
end

function parse_input_data(input_data::FITS; hdu_in = nothing)
   if hdu_in === nothing
        if length(input_data) > 1
            throw(ArgumentError("More than one HDU is present, please specify which HDU to use with 'hdu_in' option"))
        else
            hdu_in = 1
        end
    end
    return parse_input_data(input_data[hdu_in])
end

function parse_input_data(input_data; hdu_in = nothing)
    throw(ArgumentError("Input should be in Union{String, FITS, ImageHDU}"))
end

# TODO: extend support for passing FITSHeader when FITSHeader to WCSTransform support is possible.


"""
    parse_output_projection(output_projection::WCSTransform; shape_out = nothing)
    parse_output_projection(output_projection::ImageHDU; shape_out = nothing)
    parse_output_projection(output_projection::String; hdu_number = nothing)

Parse output projection and returns a WCS object and shape of output.

# Arguments
- `output_projection`: WCS information about the image to be reprojected which can be 
                       name of a FITS file, an ImageHDU or WCSTransform.
- `shape_out`: shape of the output image.
- `hdu_number`: specifies HDU number when file name is given as input.
"""
function parse_output_projection(output_projection::WCSTransform; shape_out = nothing)
    if shape_out === nothing
        throw(ArgumentError("Need to specify shape when specifying output_projection as WCS object"))
    elseif length(shape_out) == 0
        throw(DomainError(shape_out, "The shape of the output image should not be an empty tuple"))
    end

    return output_projection, shape_out
end

function parse_output_projection(output_projection::ImageHDU; shape_out = nothing)
    wcs_out = WCS.from_header(read_header(output_projection, String))[1]
    if shape_out === nothing
        shape_out = size(output_projection)
    end
    if length(shape_out) == 0
        throw(DomainError(shape_out, "The shape of the output image should not be an empty tuple"))
    end
    return wcs_out, shape_out
end

function parse_output_projection(output_projection::String; hdu_number = nothing)
    hdu_list = FITS(output_projection)
    if hdu_number === nothing
        wcs_out = WCS.from_header(read_header(hdu_list[1], String))[1]
        hdu_number = 1
    else
        wcs_out = WCS.from_header(read_header(hdu_list[hdu_number], String))[1]
    end
    
    if hdu_list[hdu_number] isa ImageHDU
        shape_out = size(hdu_list[hdu_number])
    else    
        throw(ArgumentError("Given FITS file doesn't have ImageHDU"))
    end
    
    return wcs_out, shape_out
end

function parse_output_projection(output_projection; shape_out = nothing)
    throw(ArgumentError("output_projection should be in  Union{String, WCSTransform, FITSHeader}"))
end

