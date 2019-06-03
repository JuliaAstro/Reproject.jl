@testset "input parser" begin
    fname = tempname() * ".fits"
    f = FITS(fname, "w")
    inhdr = FITSHeader(["FLTKEY", "INTKEY", "BOOLKEY", "STRKEY", "COMMENT",
                        "HISTORY"],
                       [1.0, 1, true, "string value", nothing, nothing],
                       ["floating point keyword",
                        "",
                        "boolean keyword",
                        "string value",
                        "this is a comment",
                        "this is a history"])

    indata = reshape(Float32[1:100;], 5, 20)
    write(f, indata; header=inhdr)
    
    @testset "ImageHDU type" begin
        result = parse_input_data(f[1])
        @test result[1] isa Array
        @test result[2] isa WCSTransform
    end
    
    @testset "Single HDU FITS file" begin
        result = parse_input_data(f)
        @test result[1] isa Array
        @test result[2] isa WCSTransform
    end
    close(f)
    
    @testset "String filename input" begin
        result = parse_input_data(fname)
        @test result[1] isa Array
        @test result[2] isa WCSTransform
    end
    
    f = FITS(fname, "w")
    write(f, indata; header=inhdr)
    write(f, indata; header=inhdr)
    
    @testset "Multiple HDU FITS file" begin
        
        @test_throws ArgumentError parse_input_data(f) 

        result = parse_input_data(f, hdu_in = 2)
        @test result[1] isa Array
        @test result[2] isa WCSTransform

        close(f)
        result = parse_input_data(fname, hdu_in = 1)
        @test result[1] isa Array
        @test result[2] isa WCSTransform
        @test_throws ArgumentError parse_input_data(fname)
    end
    
    @testset "invalid input" begin
        @test_throws ArgumentError parse_input_data(1:40, hdu_in = 12)
    end
        
end

@testset "output parser" begin
    fname = tempname() * ".fits"
    f = FITS(fname, "w")
    inhdr = FITSHeader(["FLTKEY", "INTKEY", "BOOLKEY", "STRKEY", "COMMENT",
                        "HISTORY"],
                       [1.0, 1, true, "string value", nothing, nothing],
                       ["floating point keyword",
                        "",
                        "boolean keyword",
                        "string value",
                        "this is a comment",
                        "this is a history"])

    indata = reshape(Float32[1:100;], 5, 20)
    write(f, indata; header=inhdr)
    
    @testset "ImageHDU type" begin
        result = parse_output_projection(f[1])
        @test result[1] isa WCSTransform
        @test result[2] isa Tuple
        @test parse_output_projection(f[1], shape_out = (12,12))[1] isa WCSTransform
    end
    close(f)
    
    @testset "String filename" begin
        result = parse_output_projection(fname)
        @test result[1] isa WCSTransform
        @test result[2] isa Tuple
        @test parse_output_projection(fname, hdu_number = 1)[1] isa WCSTransform
    end
    
    @testset "invalid input" begin
        @test_throws ArgumentError parse_output_projection(1:40, shape_out = (12,12))
    end
    
    wcs = WCSTransform(2;
                          cdelt = [-0.066667, 0.066667],
                          ctype = ["RA---AIR", "DEC--AIR"],
                          crpix = [-234.75, 8.3393],
                          crval = [0., -90],
                          pv    = [(2, 1, 45.0)])
    
    @testset "WCSTransform input" begin
        @test_throws ArgumentError parse_output_projection(wcs)
        @test_throws DomainError parse_output_projection(wcs, shape_out = ())
        
        result = parse_output_projection(wcs, shape_out = (12,12))
        @test result[1] isa WCSTransform
        @test result[2] isa Tuple
    end
        
end

