@testset "reproject-core" begin
    if !isfile("data/gc_2mass_k.fits")
        mkpath("data")
        download("https://astropy.stsci.edu/data/galactic_center/gc_2mass_k.fits", "data/gc_2mass_k.fits")
    end
    if !isfile("data/gc_msx_e.fits")
        mkpath("data")
        download("https://astropy.stsci.edu/data/galactic_center/gc_msx_e.fits", "data/gc_msx_e.fits")
    end

    imgin = FITS("data/gc_msx_e.fits")         # project this
    imgout = FITS("data/gc_2mass_k.fits")        # into this coordinate

    hdu1 = astropy.io.fits.open("data/gc_2mass_k.fits")[1]
    hdu2 = astropy.io.fits.open("data/gc_msx_e.fits")[1]

    function check_diff(arr1, arr2)
        diff = 1e-3
        count = 0
        for i in 1 : size(arr1)[1] - 1
            for j in 1 : size(arr2)[2] - 1
                if abs(arr1[i,j] - arr2[j,i]) > diff
                    count+=1
                end
            end
        end
        return  iszero(count)
    end

    @test check_diff(reproject(imgin, imgout, order = 0)[1], rp.reproject_interp(hdu2, hdu1.header, order = 0)[1]) == true
    @test check_diff(reproject(imgout, imgin, order = 0)[1], rp.reproject_interp(hdu1, hdu2.header, order = 0)[1]) == true
    @test check_diff(reproject(imgin, imgout, order = 1)[1], rp.reproject_interp(hdu2, hdu1.header, order = 1)[1]) == true
    @test check_diff(reproject(imgin, imgout, order = 2)[1], rp.reproject_interp(hdu2, hdu1.header, order = 2)[1]) == true
    @test check_diff(reproject(imgin[1], imgout[1], shape_out = (1000,1000))[1],
            rp.reproject_interp(hdu2, astropy.wcs.WCS(hdu1.header), shape_out = (1000,1000))[1]) == true

    wcs = WCSTransform(2; ctype = ["RA---AIR", "DEC--AIR"], radesys = "UNK")
    @test_throws ArgumentError reproject(imgin, wcs, shape_out = (100,100))

    fname = tempname() * ".fits"
    f = FITS(fname, "w")
    inhdr = FITSHeader(["CTYPE1", "CTYPE2", "RADESYS", "FLTKEY", "INTKEY", "BOOLKEY", "STRKEY", "COMMENT",
                        "HISTORY"],
                       ["RA---TAN", "DEC--TAN", "UNK", 1.0, 1, true, "string value", nothing, nothing],
                       ["",
                        "",
                        "",
                        "floating point keyword",
                        "",
                        "boolean keyword",
                        "string value",
                        "this is a comment",
                        "this is a history"])

    indata = reshape(Float32[1:100;], 5, 20)
    write(f, indata; header=inhdr)
    @test_throws ArgumentError reproject(f[1], imgin, shape_out = (100,100))
    close(f)
end
