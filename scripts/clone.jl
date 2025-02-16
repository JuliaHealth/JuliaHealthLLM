using LibGit2
using Downloads
using Printf

repos = [
    "https://github.com/JuliaHealth/MedEval3D.jl.git", #Example, can add more repos here
]

data_dir = "data/exp_raw"

if !isdir(data_dir)
    mkdir(data_dir)
end

for repo in repos
    repo_name = split(repo, "/")[end]
    repo_path = joinpath(data_dir, replace(repo_name, ".git" => ""))
    
    if isdir(repo_path)
        @printf("Skipping %s, already cloned.\n", repo)
    else
        try
            LibGit2.clone(repo, repo_path)
            @printf("Successfully cloned %s\n", repo)
        catch e
            @printf("Failed to clone %s: %s\n", repo, e)
        end
    end
end