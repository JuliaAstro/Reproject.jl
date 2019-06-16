function reproject(input_data, output_projection; shape_out = nothing, order = 1, hdu_in = 1, hdu_out = 1, return_footprint = true)
    if input_data isa ImageHDU
        array_in, wcs_out = parse_input_data(input_data)
    else
        array_in, wcs_out = parse_input_data(input_data, hdu_in)
    end
    
    if output_projection isa FITS || output_projection isa String
        wcs_in, shape_out = parse_output_projection(output_projection, hdu_out)
    else
        wcs_in, shape_out = parse_output_projection(output_projection, shape_out)
    end
    
    type_in = wcs_to_celestial_frame(wcs_in)
    type_out = wcs_to_celestial_frame(wcs_out)
    
    if type_in == type_out
        return array_in
    end
    
    img_out = fill!(zeros(shape_out), NaN)
    
    if order == 0
        itp = interpolate(array_in, BSpline(Constant()))
    elseif order == 1
        itp = interpolate(array_in, BSpline(Linear()))
    else
        itp = interpolate(array_in, BSpline(Quadratic(InPlace(OnCell()))))
    end
    
    for i in 1:shape_out[1]
        for j in 1:shape_out[2]
            pix_cord_in = [float(i); float(j)]
            world_cord_in = pix_to_world(wcs_in, pix_cord_in)

            if type_in == "ICRS"
                cord_in = ICRSCoords(deg2rad(world_cord_in[1]), deg2rad(world_cord_in[2]))
            elseif type_in == "Gal"
                cord_in = GalCoords(deg2rad(world_cord_in[1]), deg2rad(world_cord_in[2]))
            elseif type_in == "FK5"
                cord_in = FK5Coords{wcs_in.equinox}(deg2rad(world_cord_in[1]), deg2rad(world_cord_in[2]))
            else
                throw(ArgumentError("Unsupported input WCS coordinate type"))
            end

            if type_out == "ICRS"
                cord_out = convert(ICRSCoords, cord_in)
            elseif type_out == "Gal"
                cord_out = convert(GalCoords, cord_in)
            elseif type_out == "FK5"
                cord_out = convert(FK5Coords{wcs_out.equinox}, cord_in)
            else
                throw(ArgumentError("Unsupported output WCS coordinate type"))
            end

            pix_cord_out = world_to_pix(wcs_out, [rad2deg(lon(cord_out)), rad2deg(lat(cord_out))])

            if 1 <= pix_cord_out[1] <= size(array_in)[1] && 1 <= pix_cord_out[2] <= size(array_in)[2] 
                img_out[i,j] = itp(pix_cord_out[1], pix_cord_out[2])
            end
        end
    end
    
    if return_footprint
        return img_out, map(x -> x !== NaN ? 1.0 : 0.0, img_out)
    else
        return img_out
    end
end

