"""
    HDUSelector

An HDU within a FITS file, selected either by its 1-based position (an integer) or by its `EXTNAME` (a string or symbol).
"""
const HDUSelector = Union{Integer, AbstractString, Symbol}

"""
    select_hdu(x, hdu::HDUSelector)

Select an HDU from a FITS file name or a vector of HDUs, deferring to `FITSFiles.fits` and its indexing. Anything else (an HDU, a WCSTransform, a data/transform tuple) already refers to a single item and passes through unchanged.
"""
select_hdu(x, ::HDUSelector) = x
select_hdu(path::AbstractString, hdu::HDUSelector) = fits(path)[hdu]
select_hdu(hdus::AbstractVector{<:HDU}, hdu::HDUSelector) = hdus[hdu]

"""
    parse_input_data(input_data, hdu_in::HDUSelector = 1)

Parse input data and return an Array and WCS object.

# Arguments
- `input_data`: image to reproject which can be the name of a FITS file, an HDU, a vector of HDUs as returned by `FITSFiles.fits`, or a tuple of an image matrix and a WCSTransform.
- `hdu_in`: selects the HDU when `input_data` is a file name or a vector of HDUs.
"""
function parse_input_data(input_data, hdu_in::HDUSelector = 1)
    return data_and_wcs(select_hdu(input_data, hdu_in))
end

data_and_wcs(hdu::HDU) = hdu.data, WCS(hdu)
data_and_wcs(input_data::Tuple{AbstractArray, WCSTransform}) = input_data

"""
    parse_output_projection(output_projection, shape_out = nothing; hdu_out::HDUSelector = 1)

Parse the output projection and return a WCS object and the shape of the output.

# Arguments
- `output_projection`: WCS information about the image to be reprojected which can be the name of a FITS file, an HDU, a vector of HDUs, or a WCSTransform.
- `shape_out`: shape of the output image. Defaults to the data size of the selected HDU when one is given.
- `hdu_out`: selects the HDU when `output_projection` is a file name or a vector of HDUs.
"""
function parse_output_projection(output_projection, shape_out = nothing; hdu_out::HDUSelector = 1)
    return wcs_and_shape(select_hdu(output_projection, hdu_out), shape_out)
end

function wcs_and_shape(wcs::WCSTransform, shape_out)
    if shape_out === nothing
        throw(ArgumentError("`shape_out` must be given when the output projection is a WCSTransform"))
    end
    validate_shape(shape_out)
    return wcs, shape_out
end

function wcs_and_shape(hdu::HDU, shape_out)
    if !(hdu isa HDU{Primary} || hdu isa HDU{Image})
        throw(ArgumentError("Given FITS file doesn't have an image HDU"))
    end
    shape = something(shape_out, size(hdu))
    validate_shape(shape)
    return WCS(hdu), shape
end

function validate_shape(shape_out)
    if length(shape_out) == 0
        throw(DomainError(shape_out, "The shape of the output image should not be an empty tuple."))
    end
end
