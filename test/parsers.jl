using Reproject: parse_input_data, parse_output_projection
@testset "input parser" begin
    fname = tempname() * ".fits"
    inhdr = [Card("FLTKEY", 1.0, "floating point keyword"),
             Card("INTKEY", 1),
             Card("BOOLKEY", true, "boolean keyword"),
             Card("STRKEY", "string value", "string value"),
             Card("COMMENT", "this is a comment"),
             Card("HISTORY", "this is a history")]

    indata = reshape(Float32[1:100;], 5, 20)
    hdu = HDU(indata, inhdr)
    write(fname, [hdu])

    @testset "HDU type" begin
        result = parse_input_data(hdu)
        @test result[1] isa Array
        @test result[2] isa WCSTransform
    end

    @testset "data matrix and WCSTransform tuple" begin
        wcs = WCS(2;
                  cdelt = [-0.066667, 0.066667],
                  ctype = ["RA---AIR", "DEC--AIR"],
                  crpix = [-234.75, 8.3393],
                  crval = [0., -90],
                  pv    = [(2, 1, 45.0)])
        result = parse_input_data((indata, wcs))
        @test result[1] isa Array
        @test result[2] isa WCSTransform
    end

    @testset "Single HDU FITS file" begin
        result = parse_input_data(fits(fname), 1)
        @test result[1] isa Array
        @test result[2] isa WCSTransform
    end

    @testset "String filename input" begin
        result = parse_input_data(fname, 1)
        @test result[1] isa Array
        @test result[2] isa WCSTransform
    end

    write(fname, [hdu, HDU(Image, indata, [Card("EXTNAME", "SCI"); inhdr])])

    @testset "Multiple HDU FITS file" begin
        result = parse_input_data(fits(fname), 2)
        @test result[1] isa Array
        @test result[2] isa WCSTransform

        result = parse_input_data(fname, 1)
        @test result[1] isa Array
        @test result[2] isa WCSTransform
    end

    @testset "HDU selection by EXTNAME" begin
        result = parse_input_data(fname, "SCI")
        @test result[1] isa Array
        @test result[2] isa WCSTransform

        result = parse_input_data(fits(fname), :SCI)
        @test result[1] isa Array
        @test result[2] isa WCSTransform

        result = parse_output_projection(fname, "SCI")
        @test result[1] isa WCSTransform
        @test result[2] isa Tuple
    end
end

@testset "output parser" begin
    fname = tempname() * ".fits"
    inhdr = [Card("FLTKEY", 1.0, "floating point keyword"),
             Card("INTKEY", 1),
             Card("BOOLKEY", true, "boolean keyword"),
             Card("STRKEY", "string value", "string value"),
             Card("COMMENT", "this is a comment"),
             Card("HISTORY", "this is a history")]

    indata = reshape(Float32[1:100;], 5, 20)
    hdu = HDU(indata, inhdr)
    write(fname, [hdu])

    @testset "HDU type" begin
        result = parse_output_projection(hdu, (12,12))
        @test result[1] isa WCSTransform
        @test result[2] isa Tuple
        @test_throws DomainError parse_output_projection(hdu, ())
    end

    @testset "String filename" begin
        result = parse_output_projection(fname, 1)
        @test result[1] isa WCSTransform
        @test result[2] isa Tuple
    end

    wcs = WCS(2;
              cdelt = [-0.066667, 0.066667],
              ctype = ["RA---AIR", "DEC--AIR"],
              crpix = [-234.75, 8.3393],
              crval = [0., -90],
              pv    = [(2, 1, 45.0)])

    @testset "WCSTransform input" begin
        result = parse_output_projection(wcs, (12,12))
        @test result[1] isa WCSTransform
        @test result[2] isa Tuple
        @test_throws DomainError parse_output_projection(wcs, ())
    end
end
