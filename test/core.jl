@testset "reproject-core" begin
    data = ensure_artifact_installed("galactic_center", joinpath(pkgdir(Reproject), "Artifacts.toml"))
    gc_msx_e = joinpath(data, "gc_msx_e.fits")
    gc_2mass_k = joinpath(data, "gc_2mass_k.fits")

    imgin = fits(gc_msx_e)    # project this
    imgout = fits(gc_2mass_k) # into this coordinate

    hdu1 = astropy.io.fits.open(gc_2mass_k)[0]
    hdu2 = astropy.io.fits.open(gc_msx_e)[0]

    # These compare element-wise against Python reproject, whose behavior has changed
    # since these tests were written against the reproject = 0.5 pin:
    #
    # - NaN footprint: reproject >= 0.6 masks the outer half-pixel band at the upper
    #   edges, fixing an off-by-padded-shape bound that v0.5 (and formerly this package)
    #   shared. See https://github.com/astropy/reproject/commit/cfae5c88
    #   (merged in https://github.com/astropy/reproject/pull/186).
    #
    # - order = 2 needs an absolute tolerance floor: the quadratic kernel diverged from
    #   Interpolations.jl at background (near-zero) pixels after upstream replaced edge
    #   padding with coordinate clamping (https://github.com/astropy/reproject/pull/352,
    #   v0.11.0) and added global scipy spline_filter prefiltering for order >= 2
    #   (https://github.com/astropy/reproject/pull/532, v0.19.0). Differences are
    #   <= ~2e-5 absolute against a ~3e-3 peak, so atol = 1e-4 covers implementation
    #   noise without hiding real regressions.
    @test isapprox(reproject(imgin, imgout, order = 0)[1]', pyconvert(Matrix, rp.reproject_interp(hdu2, hdu1.header, order = 0)[0]), nans = true, rtol = 1e-7)
    @test isapprox(reproject(imgout, imgin, order = 0)[1]', pyconvert(Matrix, rp.reproject_interp(hdu1, hdu2.header, order = 0)[0]), nans = true, rtol = 1e-6)
    @test isapprox(reproject(imgin, imgout, order = 1)[1]', pyconvert(Matrix, rp.reproject_interp(hdu2, hdu1.header, order = 1)[0]), nans = true, rtol = 1e-7)
    @test isapprox(reproject(imgin, imgout, order = 2)[1]', pyconvert(Matrix, rp.reproject_interp(hdu2, hdu1.header, order = 2)[0]), nans = true, rtol = 6e-2, atol = 1e-4)
    @test isapprox(reproject(imgin[1], imgout[1], shape_out = (1000,1000))[1]',
                   pyconvert(Matrix, rp.reproject_interp(hdu2, astropy.wcs.WCS(hdu1.header), shape_out = (1000,1000))[0]), nans = true, rtol = 1e-7)

    wcs = WCS(2; ctype = ["RA---AIR", "DEC--AIR"], radesys = "UNK")
    @test_throws ArgumentError reproject(imgin, wcs, shape_out = (100,100))

    inhdr = [Card("CTYPE1", "RA---TAN"),
             Card("CTYPE2", "DEC--TAN"),
             Card("RADESYS", "UNK"),
             Card("FLTKEY", 1.0, "floating point keyword"),
             Card("INTKEY", 1),
             Card("BOOLKEY", true, "boolean keyword"),
             Card("STRKEY", "string value", "string value"),
             Card("COMMENT", "this is a comment"),
             Card("HISTORY", "this is a history")]

    indata = reshape(Float32[1:100;], 5, 20)
    hdu = HDU(indata, inhdr)
    @test_throws ArgumentError reproject(hdu, imgin, shape_out = (100,100))
end
