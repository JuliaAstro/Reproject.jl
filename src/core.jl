"""
    reproject(input_data, output_projection; shape_out = nothing, order = 1, hdu_in = 1, hdu_out = 1)

Reprojects image data to a new projection using interpolation.

# Arguments
- `input_data`: Image data which is being reprojected.
                It can be an HDU, a vector of HDUs as returned by `FITSFiles.fits`,
                name of a FITS file or a tuple of image matrix and WCSTransform.
- `output_projection`: Frame in which data is reprojected.
                       Frame can be taken from WCSTransform object, HDU, vector of HDUs or name of FITS file.
- `shape_out`: Shape of image after reprojection; defaults to the data size of the selected HDU when the output projection is given as an HDU, vector of HDUs, or name of FITS file.
- `order`: Order of interpolation.
           0: Nearest-neighbor
           1: Linear
           2: Quadratic
- `hdu_in`: Used to select the HDU when giving input as a vector of HDUs or name of FITS file, either a 1-based integer index or an `EXTNAME` string or symbol.
- `hdu_out:` Used to select the HDU when giving output projection as a vector of HDUs or name of FITS file, either a 1-based integer index or an `EXTNAME` string or symbol.
"""
function reproject(input_data, output_projection; shape_out = nothing, order::Int = 1, hdu_in::HDUSelector = 1, hdu_out::HDUSelector = 1)
    array_in, wcs_source = parse_input_data(input_data, hdu_in)
    wcs_target, shape_out = parse_output_projection(output_projection, shape_out; hdu_out)

    frame_source = celestial_frame(wcs_source)
    frame_target = celestial_frame(wcs_target)

    img_out = fill(NaN, shape_out)
    itp = interpolator(array_in, order)
    shape_in = size(array_in)

    for i in 1:shape_out[1]
        for j in 1:shape_out[2]
            pix_coord_target = [float(i), float(j)]
            world_coord_target = pixel_to_world(wcs_target, pix_coord_target)

            coord_target = frame_target(deg2rad(world_coord_target[1]), deg2rad(world_coord_target[2]))
            coord_source = convert(frame_source, coord_target)

            pix_coord_source = world_to_pixel(wcs_source, [rad2deg(SkyCoords.lon(coord_source)), rad2deg(SkyCoords.lat(coord_source))])

            if 0.5 <= pix_coord_source[1] <= shape_in[1] + 0.5 && 0.5 <= pix_coord_source[2] <= shape_in[2] + 0.5
                img_out[i,j] = itp(pix_coord_source[1], pix_coord_source[2])
            end
        end
    end

    return img_out, (!isnan).(img_out)
end


"""
    interpolator(array_in, order::Int; padding = Flat())

Returns an interpolator with the given array and order of interpolation.

`padding` is the Interpolations.jl boundary condition used for evaluations that
fall in the outer half-pixel border of the array, replacing the edge padding
that was previously applied to a copy of the input.
"""
function interpolator(array_in::AbstractArray, order::Int; padding = Flat())
    if order == 0
        itp = interpolate(array_in, BSpline(Constant()))
    elseif order == 1
        itp = interpolate(array_in, BSpline(Linear()))
    else
        itp = interpolate(array_in, BSpline(Quadratic(InPlace(OnCell()))))
    end

    return extrapolate(itp, padding)
end
