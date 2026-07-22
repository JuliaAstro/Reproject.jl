using Documenter

DocMeta.setdocmeta!(Reproject, :DocTestSetup, :(using Reproject); recursive = true)

# Trailing digits of printed floats can differ by one ulp across Julia versions
# and platforms, so compare doctest output only down to 8 fractional digits.
doctest(Reproject; doctestfilters = [r"(\d\.\d{8})\d+" => s"\1"])
