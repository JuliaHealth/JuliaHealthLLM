# JuliaHealthLLM

A proof of concept exploration of using LLM technologies across the JuliaHealth ecosystem. 

## Initializing Project

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

## Directory Layout

Here is how the layout of this project is made: 

```
│projectdir          <- Project's main folder. It is initialized as a Git
│                       repository with a reasonable .gitignore file.
│
├── _research        <- WIP scripts, code, notes, comments,
│   |                   to-dos and anything in an alpha state.
│   └── tmp          <- Temporary data folder.
│
├── data             <- **Immutable and add-only!**
│   ├── sims         <- Data resulting directly from simulations.
│   ├── exp_pro      <- Data from processing experiments.
│   └── exp_raw      <- Raw experimental data.
│
├── plots            <- Self-explanatory.
├── notebooks        <- Jupyter, Weave or any other mixed media notebooks.
│
├── papers           <- Scientific papers resulting from the project.
│
├── scripts          <- Various scripts, e.g. simulations, plotting, analysis,
│   │                   The scripts use the `src` folder for their base code.
│   └── intro.jl     <- Simple file that uses DrWatson and uses its greeting.
│
├── src              <- Source code for use in this project. Contains functions,
│                       structures and modules that are used throughout
│                       the project and in multiple scripts.
│
├── README.md        <- Optional top-level README for anyone using this project.
├── .gitignore       <- by default ignores _research, data, plots, videos,
│                       notebooks and latex-compilation related files.
│
├── Manifest.toml    <- Contains full list of exact package versions used currently.
└── Project.toml     <- Main project file, allows activation and installation.
                        Includes DrWatson by default.
```

# License Notices

This repository contains code and data from several external repositories. Their respective licenses are:

## CommonDataModel
The OHDSI CommonDataModel is licensed under Creative Commons CC BY-SA 4.0. See their [LICENSE](https://github.com/OHDSI/CommonDataModel/blob/561c93dc650b85dd340842ec22b3d8498ad9215b/docs/site_libs/jqueryui-1.13.2/LICENSE.txt) file for details.

## FunSQL.jl
This project includes content from [FunSQL.jl](https://github.com/MechanicalRabbit/FunSQL.jl), licensed under the [MIT License](https://github.com/MechanicalRabbit/FunSQL.jl?tab=License-1-ov-file).

## OMOPCDMCohortCreator.jl  
This project includes content from [OMOPCDMCohortCreator.jl](https://github.com/JuliaHealth/OMOPCDMCohortCreator.jl), licensed under the [Apache License 2.0](https://github.com/JuliaHealth/OMOPCDMCohortCreator.jl?tab=License-1-ov-file).

## TheBookOfOhdsi
This project includes content from [TheBookOfOhdsi](https://github.com/OHDSI/TheBookOfOhdsi), licensed under [CC0 1.0 Universal (Public Domain Dedication)](https://github.com/OHDSI/TheBookOfOhdsi?tab=CC0-1.0-1-ov-file).
