using Reproject: celestial_frame
using SkyCoords: ICRSCoords, GalCoords, FK5Coords

@testset "celestial frame from WCS" begin
    wcs1 = WCS(2;
               ctype = ["RA---AIR", "DEC--AIR"],
               )
    wcs2 = WCS(2;
               ctype = ["RA---AIR", "DEC--AIR"],
               equinox = 1888.67
               )
    wcs3 = WCS(2;
               ctype = ["RA---AIR", "DEC--AIR"],
               equinox = 2000
               )
    wcs4 = WCS(2;
               ctype = ["GLON--", "GLAT--"],
               )
    wcs5 = WCS(2;
               ctype = ["TLON", "TLAT"],
              )
    wcs6 = WCS(2;
               ctype = ["RA---AIR", "DEC--AIR"],
               radesys = "UNK"
              )

    @test celestial_frame(wcs1) == ICRSCoords
    # FK4 (pre-1984 equinox) has no SkyCoords counterpart
    @test_throws ArgumentError celestial_frame(wcs2)
    @test celestial_frame(wcs3) == FK5Coords{2000.0}
    @test celestial_frame(wcs4) == GalCoords
    # ITRS (TLON/TLAT) has no SkyCoords counterpart
    @test_throws ArgumentError celestial_frame(wcs5)
    @test_throws ArgumentError celestial_frame(wcs6)
end

@testset "celestial frame from sliced WCS" begin
    cube = WCS(3; ctype = ["GLON-TAN", "GLAT-TAN", "VRAD"])

    # Cutout of a single channel: keeps both celestial axes
    @test celestial_frame(slice_wcs(cube, 10:20, 5:15, 3)) == GalCoords
    # Position-velocity slice: keeps longitude and velocity
    @test_throws ArgumentError celestial_frame(slice_wcs(cube, :, 7, :))
end
