using LibGit2
using Downloads

repos = [
    "https://github.com/JuliaHealth/MedEval3D.jl.git",
]

data_dir = "data/exp_raw"

if !isdir(data_dir)
    mkdir(data_dir)
end

for repo in repos
    repo_name = split(repo, "/")[end]
    repo_path = joinpath(data_dir, replace(repo_name, ".git" => ""))
    
    if isdir(repo_path)
        println("Skipping $repo, already cloned.")
    else
        try
            LibGit2.clone(repo, repo_path)
            println("Successfully cloned $repo")
        catch e
            println("Failed to clone $repo: $e")
        end
    end
end