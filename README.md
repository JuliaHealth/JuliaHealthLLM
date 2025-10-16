# JuliaHealthLLM

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ParamThakkar123.github.io/JuliaHealthLLM.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ParamThakkar123.github.io/JuliaHealthLLM.jl/dev/)
[![Build Status](https://github.com/ParamThakkar123/JuliaHealthLLM.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/ParamThakkar123/JuliaHealthLLM.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/ParamThakkar123/JuliaHealthLLM.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ParamThakkar123/JuliaHealthLLM.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This code base is using the [Julia Language](https://julialang.org/) and
[DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/)
to make a reproducible scientific project named
> JuliaHealthLLM

It is authored by Param Thakkar, Jacob S. Zelko.

To (locally) reproduce this project, do the following:

0. Download this code base. Notice that raw data are typically not included in the
   git-history and may need to be downloaded independently.
1. Open a Julia console and do:
   ```
   julia> using Pkg
   julia> Pkg.add("DrWatson") # install globally, for using `quickactivate`
   julia> Pkg.activate("path/to/this/project")
   julia> Pkg.instantiate()
   ```

This will install all necessary packages for you to be able to run the scripts and
everything should work out of the box, including correctly finding local paths.

You may notice that most scripts start with the commands:
```julia
using DrWatson
@quickactivate "JuliaHealthLLM"
```
which auto-activate the project and enable local path handling from DrWatson.

## Citing

See [`CITATION.bib`](CITATION.bib) for the relevant reference(s).

## JuliaCon Talk Video
[JuliaCon Talk on JuliaHealthLLM.jl](https://www.youtube.com/watch?v=oeYhwagpI98&t=21614s)
