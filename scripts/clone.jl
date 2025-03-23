"""
    clone_repositories(repos::Vector{String}, data_dir::String)

Clones a list of Git repositories into the specified directory.

# Arguments
- `repos::Vector{String}`: A vector of repository URLs to be cloned.
- `data_dir::String`: The directory where the repositories will be cloned.

# Behavior
- If the target directory does not exist, it will be created.
- If a repository has already been cloned (i.e., its directory exists), it will be skipped.
- If cloning fails for any repository, an error message will be printed.

# Example
```julia
repos = [
    "https://github.com/JuliaLang/julia.git",
    "https://github.com/JuliaHealth/MedEval3D.jl.git"
]
data_dir = "data/exp_raw"
clone_repositories(repos, data_dir)
```

"""
function clone_repositories(repos::Vector{String}, data_dir::String)
    # Ensure the target directory exists
    if !isdir(data_dir)
        mkdir(data_dir)
    end

    # Iterate through the list of repositories and clone them
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
end