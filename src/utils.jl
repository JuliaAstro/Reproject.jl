# TODO: Consider upstreaming this as an extension to FITSWCS.jl
"""
    celestial_frame(wcs::WCSTransform)
    celestial_frame(wcs::SlicedWCSTransform)

The `SkyCoords` coordinate type corresponding to the celestial reference frame of a WCS transform: `ICRSCoords`, `FK5Coords{equinox}`, or `GalCoords`.

A `SlicedWCSTransform` (e.g., of a cutout, or of a single channel of a data cube) takes the frame of its parent, and must keep exactly the two celestial axes of its parent.

Throws an `ArgumentError` for frames without a `SkyCoords` counterpart (e.g., FK4 or ITRS).
"""
function celestial_frame(wcs::WCSTransform)
    radesys = wcs.radesys
    if radesys == "ICRS"
        return ICRSCoords
    elseif radesys == "FK5"
        return FK5Coords{wcs.equinox}
    elseif radesys == "" && startswith(wcs.ctype[1], "GLON") && startswith(wcs.ctype[2], "GLAT")
        return GalCoords
    end
    frame = isempty(radesys) ? join(wcs.ctype, ", ") : radesys
    throw(ArgumentError("WCS celestial frame ($frame) is not supported by SkyCoords"))
end

function celestial_frame(wcs::SlicedWCSTransform)
    p = wcs.parent
    if Set(wcs.world_keep) != Set((p.lon_axis, p.lat_axis))
        kept = join(p.ctype[wcs.world_keep], ", ")
        throw(ArgumentError("Sliced WCS must keep exactly the two celestial axes of its parent, but keeps: $kept"))
    end
    return celestial_frame(p)
end
