using JuliaHealthLLM
using Documenter

DocMeta.setdocmeta!(JuliaHealthLLM, :DocTestSetup, :(using JuliaHealthLLM); recursive=true)

makedocs(;
    modules=[JuliaHealthLLM],
    authors="ParamThakkar123 <paramthakkar864@gmail.com>, TheCedarPrince <jacobszelko@gmail.com> and contributors",
    sitename="JuliaHealthLLM.jl",
    format=Documenter.HTML(;
        canonical="https://ParamThakkar123.github.io/JuliaHealthLLM.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ParamThakkar123/JuliaHealthLLM.jl",
    devbranch="master",
)
