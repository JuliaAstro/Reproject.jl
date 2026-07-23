# Reproject

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaastro.org/Reproject/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaastro.org/Reproject.jl/dev/)

[![Test](https://github.com/JuliaAstro/Reproject.jl/actions/workflows/Test.yml/badge.svg)](https://github.com/JuliaAstro/Reproject.jl/actions/workflows/Test.yml)
[![codecov](https://codecov.io/gh/juliaastro/Reproject.jl/graph/badge.svg?token=FuRiCunNhA)](https://codecov.io/gh/juliaastro/Reproject.jl)

Implementation in [Julia](https://julialang.org/) of the [`reproject`](https://github.com/astropy/reproject) package by Thomas Robitaille, part of the Astropy project.

This package can be used to reproject Astronomical Images from one world coordinate to another. By reproject we mean re-gridding of images using interpolation (i.e changing the pixel resolution, orientation, coordinate system).

## Quickstart

```julia-repl
pkg> add Reproject

julia> using Reproject

julia> result, footprint = reproject(input_data, output_projection)
```

## Applications

See [AstroImages.jl](https://juliaastro.org/AstroImages/stable/guide/reproject/) for an example of using this package with astronomical images (e.g., FITS, WCS, and plotting support).

## License

The `reproject` package is released under the terms of the BSD 3-Clause "New" or "Revised" License. The `Reproject.jl` package received written permission to be released under the MIT "Expat" License.

The authors of this package are [aquatiko](https://github.com/aquatiko) and [giordano](https://github.com/giordano).
