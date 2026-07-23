"""
    reproject(input_data, output_projection; shape_out = nothing, order = 1, hdu_in = 1, hdu_out = 1)

Reprojects image data to a new projection using interpolation.

# Arguments
- `input_data`: Image data which is being reprojected.
                It can be an HDU, a vector of HDUs as returned by `FITSFiles.fits`,
                name of a FITS file or a tuple of image matrix and WCSTransform.
- `output_projection`: Frame in which data is reprojected.
                       Frame can be taken from WCSTransform object, HDU, vector of HDUs or name of FITS file.
- `shape_out`: Shape of image after reprojection.
- `order`: Order of interpolation.
           0: Nearest-neighbor
           1: Linear
           2: Quadratic
- `hdu_in`: Used to specify HDU number when giving input as a vector of HDUs or name of FITS file.
- `hdu_out:` Used to specify HDU number when giving output projection as a vector of HDUs or name of FITS file.
"""
function reproject(input_data, output_projection; shape_out = nothing, order::Int = 1, hdu_in::Int = 1, hdu_out::Int = 1)
    if input_data isa HDU || input_data isa Tuple{AbstractArray, WCSTransform}
        array_in, wcs_out = parse_input_data(input_data)
    else
        array_in, wcs_out = parse_input_data(input_data, hdu_in)
    end

    if output_projection isa AbstractVector{<:HDU} || output_projection isa String
        wcs_in, shape_out = parse_output_projection(output_projection, hdu_out)
    else
        wcs_in, shape_out = parse_output_projection(output_projection, shape_out)
    end

    type_in = wcs_to_celestial_frame(wcs_in)
    type_out = wcs_to_celestial_frame(wcs_out)

    if type_in == type_out && shape_out === nothing
        return array_in
    end

    frame_in = if type_in == "ICRS"
        ICRSCoords
    elseif type_in == "Gal"
        GalCoords
    elseif type_in == "FK5"
        FK5Coords{wcs_in.equinox}
    else
        throw(ArgumentError("Unsupported output WCS coordinate type"))
    end

    frame_out = if type_out == "ICRS"
        ICRSCoords
    elseif type_out == "Gal"
        GalCoords
    elseif type_out == "FK5"
        FK5Coords{wcs_out.equinox}
    else
        throw(ArgumentError("Unsupported input WCS coordinate type"))
    end

    img_out = fill(NaN, shape_out)
    itp = interpolator(array_in, order)
    shape_in = size(array_in)

    for i in 1:shape_out[1]
        for j in 1:shape_out[2]
            pix_coord_in = [float(i), float(j)]
            world_coord_in = pixel_to_world(wcs_in, pix_coord_in)

            coord_in = frame_in(deg2rad(world_coord_in[1]), deg2rad(world_coord_in[2]))
            coord_out = convert(frame_out, coord_in)

            pix_coord_out = world_to_pixel(wcs_out, [rad2deg(SkyCoords.lon(coord_out)), rad2deg(SkyCoords.lat(coord_out))])

            if 0.5 <= pix_coord_out[1] <= shape_in[1] + 0.5 && 0.5 <= pix_coord_out[2] <= shape_in[2] + 0.5
                img_out[i,j] = itp(pix_coord_out[1], pix_coord_out[2])
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
