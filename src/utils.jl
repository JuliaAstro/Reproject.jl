# TODO: Consider upstreaming this as an extension to FITSWCS.jl
"""
    celestial_frame(wcs::WCSTransform)

The `SkyCoords` coordinate type corresponding to the celestial reference frame of a WCS transform: `ICRSCoords`, `FK5Coords{equinox}`, or `GalCoords`.

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
