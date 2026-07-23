# Reproject

Implementation in [Julia](https://julialang.org/) of the [`reproject`](https://github.com/astropy/reproject) package by Thomas Robitaille, part of the Astropy project.

This package can be used to reproject astronomical images from one world coordinate to another using the exported [`reproject`](@ref) function. By reproject, we mean re-gridding of images using interpolation (i.e., changing the pixel resolution, orientation, coordinate system).

## Installation

```julia-repl
pkg> add Reproject
```

## Usage

```julia-repl
julia> using Reproject

julia> result, footprint = reproject(input_data, output_projection)
```

To reproject astronomical images, primary requirements are image data (2D Matrix), world coordinate frame of the input image, and the required output frame in which it needs to be reprojected.

The image data and input frame is given together as a [`FITSFiles.HDU`](@extref), a vector of HDUs as returned by [`FITSFiles.fits`](@extref FITSFiles.fits-Tuple{IO}), or path to the FITS file in `input_data`. A keyword argument `hdu_in` can be given while using a vector of HDUs or FITS file name to specify the specific HDU in the FITS file.

The `output_projection` is the output world coordinate frame. It needs to be a [`FITSWCS.WCSTransform`](https://github.com/JuliaAstro/FITSWCS.jl), a [FITSFiles.HDU](@extref), a vector of HDUs, or the path to the FITS file. A keyword argument `hdu_out` can be given while using a vector of HDUs or FITS file name to specify the specific HDU in the FITS file. WCS information is extracted from the header when an HDU or FITS file is given as `output_projection`.

The order of the interpolation used can be specified by the `order` keyword (i.e., 0, 1 (default), 2). The dimensions of the output image can be given by the `shape_out` keyword. This can be used to change resolution.

## Example

```@setup gc
using Reproject
using Pkg.Artifacts: ensure_artifact_installed
data = ensure_artifact_installed("galactic_center", joinpath(pkgdir(Reproject), "Artifacts.toml"))
gc_msx_e = joinpath(data, "gc_msx_e.fits")
gc_2mass_k = joinpath(data, "gc_2mass_k.fits")
```

Using the following data from [astropy-data](https://www.astropy.org/astropy-data/):

```@example gc
@info "File paths:" gc_msx_e gc_2mass_k
```

we reprojects an MSX E-band image of the Galactic center (`gc_msx_e`) onto the frame of a 2MASS K-band image (`gc_2mass_k`):

```@example gc
using Reproject

result, footprint = reproject(gc_msx_e, gc_2mass_k, shape_out = (1000,1000), order = 2)
```

To look at the images, we use [`imview`](@extref AstroImages.imview) from [AstroImages.jl](@extref AstroImages :doc:`index`), which applies percentile limits, an asinh stretch, and a colormap for us:

```@example gc
using AstroImages, FITSFiles

input_image = load(gc_msx_e)
```

**Output**, reprojected onto the 2MASS frame and shown next to its footprint (blank corners are pixels outside the input image's footprint, where `footprint` is `false`):

```@example gc
using ImageCore

mosaic(imview(result), imview(footprint); nrow = 1, npad = 10)
```

For a closer look with world coordinate axes and a colorbar, we can plot the reprojected image with `implotview` and a [Makie](https://docs.makie.org/) backend. `reproject` returns a plain matrix, so we first re-attach the output frame's WCS headers with [`copyheader`](@extref AstroImages.copyheader):

```@example gc
using CairoMakie

target = load(gc_2mass_k)
fig, _ = implotview(copyheader(target, result); clims = Percent(99.6), stretch = asinhstretch, cmap = :hot)
fig
```

!!! note
    See [AstroImages.jl](@extref AstroImages :doc:`guide/reproject`) for more on using this package with astronomical images (e.g., FITS, WCS, and plotting support).

## License

The `reproject` package is released under the terms of the BSD 3-Clause "New" or "Revised" License.  The `Reproject.jl` package received written permission to be released under the MIT "Expat" License.

The authors of this package are [aquatiko](https://github.com/aquatiko) and [giordano](https://github.com/giordano).
