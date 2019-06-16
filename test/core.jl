#using Reproject: wcs_to_celestial_frame
@testset "reproject-core" begin
    if !isfile("gc_2mass_k.fits")
        download("https://astropy.stsci.edu/data/galactic_center/gc_2mass_k.fits", "gc_2mass_k.fits")
    end
    if !isfile("gc_msx_e.fits")
        download("https://astropy.stsci.edu/data/galactic_center/gc_msx_e.fits", "gc_msx_e.fits")
    end
    
    imgin = FITS("gc_msx_e.fits")         # project this
    imgout = FITS("gc_2mass_k.fits")        # into this coordinate
    
    hdu1 = astropy.io.fits.open("gc_2mass_k.fits")[1]
    hdu2 = astropy.io.fits.open("gc_msx_e.fits")[1]
    
    function check_diff(arr1, arr2)
        diff = 10e-5
        count = 0
        for i in 1 : size(arr1)[1] - 1
            for j in 1 : size(arr2)[2] - 1
                if abs(arr1[i,j] - arr2[j,i]) > diff
                    count+=1
                end
            end
        end
        return  count == 0 ? true : false
    end
    
    @test check_diff(reproject(imgin, imgout, order = 0)[1], rp.reproject_interp(hdu2, hdu1.header, order = 0)[1]) == true
    @test check_diff(reproject(imgin, imgout, order = 1)[1], rp.reproject_interp(hdu2, hdu1.header, order = 1)[1]) == true
    @test check_diff(reproject(imgin, imgout, order = 2)[1], rp.reproject_interp(hdu2, hdu1.header, order = 2)[1]) == true
    @test check_diff(reproject(imgin[1], imgout[1], shape_out = (1000,1000))[1],
            rp.reproject_interp(hdu2, astropy.wcs.WCS(hdu1.header), shape_out = (1000,1000))[1]) == true
    
end
