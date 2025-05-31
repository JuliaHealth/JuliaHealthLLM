"""
    update_julia_package_repos(repo_list::Dict{String, String})

Updates or clones Julia package repositories and maintains their status in a git repository.

This function:
1. Initializes a git repository if not already present
2. Creates a `data/exp_raw` directory if needed
3. For each repository in `repo_list`:
   - Clones new repositories or updates existing ones to latest master
4. Records the status of all repositories in `julia_repos_status.txt`
5. Commits changes to the main repository

# Arguments
- `repo_list`: Dictionary mapping repository names (String) to their Git URLs (String)

# Throws
- Error if git repository root cannot be determined or created
- Prints detailed error messages and exits with status 1 on failure

# Examples
```julia
julia> repos = Dict("Pkg" => "https://github.com/JuliaLang/Pkg.jl.git",
                    "Example" => "https://github.com/JuliaLang/Example.jl.git")
julia> update_julia_package_repos(repos)
Working in directory: /current/path
Created directory: /current/path/data/exp_raw
Cloning new repository: Pkg
Cloned Pkg successfully
Cloning new repository: Example
Cloned Example successfully
...
Process completed!
```
"""
function update_julia_package_repos(repo_list::Dict{String, String})
    try
        base_dir = "./data/exp_raw"
        
        git_root = nothing
        repo = nothing
        try
            repo = LibGit2.GitRepo(".")
            git_root = LibGit2.path(repo)
        catch
            println("Not in a git repository, initializing new one...")
            repo = LibGit2.init(pwd())
            git_root = LibGit2.path(repo)
        end
        
        if isnothing(git_root) || !isdir(git_root)
            error("Could not determine or create git repository root")
        end

        println("Working in directory: $git_root")
        
        full_base_dir = joinpath(git_root, base_dir)
        if !isdir(full_base_dir)
            mkpath(full_base_dir)
            println("Created directory: $full_base_dir")
        end

        for (name, url) in repo_list
            repo_dir = joinpath(full_base_dir, name)
            
            if isdir(repo_dir)
                println("\nUpdating existing repository: $name")
                sub_repo = LibGit2.GitRepo(repo_dir)
                try
                    LibGit2.fetch(sub_repo)
                    remote = LibGit2.get(LibGit2.GitRemote, sub_repo, "origin")
                    branch = LibGit2.lookup_branch(sub_repo, "master")
                    commit = LibGit2.lookup(LibGit2.GitCommit, sub_repo, LibGit2.target(branch))
                    LibGit2.reset!(sub_repo, commit, LibGit2.Consts.RESET_HARD)
                    println("Updated $name to latest master")
                finally
                    LibGit2.close(sub_repo)
                end
            else
                println("\nCloning new repository: $name")
                LibGit2.clone(url, repo_dir)
                println("Cloned $name successfully")
            end
        end

        output_file = joinpath(git_root, "julia_repos_status.txt")
        open(output_file, "w") do io
            println(io, "Julia Package Repositories Status - Updated on: ", Dates.now())
            println(io, "=========================================")
            
            for name in keys(repo_list)
                repo_dir = joinpath(full_base_dir, name)
                sub_repo = LibGit2.GitRepo(repo_dir)
                try
                    commit_hash = string(LibGit2.head_oid(sub_repo))
                    println(io, "Repository: $name")
                    println(io, "Commit: $commit_hash")
                    println(io, "")
                    println("Recorded status for $name: $commit_hash")
                finally
                    LibGit2.close(sub_repo)
                end
            end
        end
        
        println("\nChecking for changes to commit...")
        status = LibGit2.status(repo)
        
        if !isempty(status)
            println("Committing changes...")
            idx = LibGit2.GitIndex(repo)
            LibGit2.add!(idx, base_dir)
            LibGit2.add!(idx, "julia_repos_status.txt")
            LibGit2.write!(idx)
            
            tree_id = LibGit2.write_tree!(idx)
            parents = LibGit2.isdetached(repo) ? [] : [LibGit2.head_oid(repo)]
            sig = LibGit2.default_signature(repo)
            commit_msg = "Updated Julia package reference repositories in data/exp_raw - $(Dates.now())"
            LibGit2.commit(repo, commit_msg; tree=tree_id, parents=parents, author=sig, committer=sig)
            println("Changes committed successfully")
        else
            println("No changes to commit - repositories were already up to date")
        end
        
        println("\nProcess completed!")
        println("Repository status recorded in: $output_file")
        println("Current git status:")
        for (file, stat) in LibGit2.status(repo)
            println("$file: $(stat.flags)")
        end
        
        LibGit2.close(repo)
        
    catch e
        println("Error occurred: ", e)
        println("Failed to update Julia package repositories. Please ensure:")
        println("1. Git is installed and accessible")
        println("2. You have write permissions in the current directory")
        println("3. You have internet access to clone/pull from GitHub")
        exit(1)
    end
end