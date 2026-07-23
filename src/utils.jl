"""
    wcs_to_celestial_frame(wcs::WCSTransform)

Returns the reference frame of a WCSTransform.
The reference frame supported in Julia are FK5, ICRS and Galactic.
"""
function wcs_to_celestial_frame(wcs::WCSTransform)
    radesys = wcs.radesys

    xcoord = wcs.ctype[1][1:4]
    ycoord = wcs.ctype[2][1:4]

    if radesys == ""
        if xcoord == "GLON" && ycoord == "GLAT"
            radesys = "Gal"
        elseif xcoord == "TLON" && ycoord == "TLAT"
            radesys = "ITRS"
        end
    end

    return radesys
end
