"""
    parse_input_data(input_data::HDU)
    parse_input_data(input_data::Tuple{AbstractArray, WCSTransform})
    parse_input_data(input_data::String, hdu_in)
    parse_input_data(input_data::AbstractVector{<:HDU}, hdu_in)

Parse input data and returns an Array and WCS object.

# Arguments
- `input_data`: image to reproject which can be name of a FITS file,
                an HDU or a vector of HDUs as returned by `FITSFiles.fits`.
- `hdu_in`: used to set HDU to use when more than one HDU is present.
"""
function parse_input_data(input_data::HDU)
    return input_data.data, WCS(input_data)
end

function parse_input_data(input_data::Tuple{AbstractArray, WCSTransform})
    return input_data[1], input_data[2]
end

function parse_input_data(input_data::String, hdu_in)
    return parse_input_data(fits(input_data), hdu_in)
end

function parse_input_data(input_data::AbstractVector{<:HDU}, hdu_in)
    return parse_input_data(input_data[hdu_in])
end


"""
    parse_output_projection(output_projection::WCSTransform, shape_out)
    parse_output_projection(output_projection::HDU, shape_out)
    parse_output_projection(output_projection::String, hdu_number)
    parse_output_projection(output_projection::AbstractVector{<:HDU}, hdu_number)

Parse output projection and returns a WCS object and shape of output.

# Arguments
- `output_projection`: WCS information about the image to be reprojected which can be
                       name of a FITS file, an HDU, a vector of HDUs or a WCSTransform.
- `shape_out`: shape of the output image.
- `hdu_number`: specifies HDU number when file name is given as input.
"""
function parse_output_projection(output_projection::WCSTransform, shape_out)
    if length(shape_out) == 0
        throw(DomainError(shape_out, "The shape of the output image should not be an empty tuple"))
    end

    return output_projection, shape_out
end

function parse_output_projection(output_projection::HDU, shape_out)
    wcs_out = WCS(output_projection)
    if shape_out === nothing
        shape_out = size(output_projection)
    end
    if length(shape_out) == 0
        throw(DomainError(shape_out, "The shape of the output image should not be an empty tuple"))
    end
    return wcs_out, shape_out
end

function parse_output_projection(output_projection::String, hdu_number)
    return parse_output_projection(fits(output_projection), hdu_number)
end

function parse_output_projection(output_projection::AbstractVector{<:HDU}, hdu_number)
    hdu = output_projection[hdu_number]
    if !(hdu isa HDU{Primary} || hdu isa HDU{Image})
        throw(ArgumentError("Given FITS file doesn't have an image HDU"))
    end

    return WCS(hdu), size(hdu)
end
