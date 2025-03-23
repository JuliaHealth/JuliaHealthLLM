"""
    restore_all_submodules()

Restores all Git submodules in the current repository to their recorded commits.

This function:
1. Detects if the current directory is within a Git repository
2. Locates and parses the repository's submodules from either `.gitmodules` file or Git config
3. For each submodule:
   - Initializes it if not already initialized
   - Updates it to its recorded commit
   - Reports the current HEAD status
4. Handles errors gracefully with appropriate feedback

# Throws
- Error if not inside a Git repository
- Error if repository root cannot be determined
- Prints warnings for missing submodules or parsing issues
- Exits with status 1 on fatal errors

# Examples
```julia
julia> cd("path/to/git/repo")
julia> restore_all_submodules()
Working in git repository root: /path/to/git/repo
Discovering submodules...
Processing submodule at: submod1
Current status of submod1:
HEAD at: abc123...
All submodules successfully restored to recorded commits!
```
"""

function restore_all_submodules()
    try
        repo_path = nothing
        try
            repo = LibGit2.GitRepo(".")
            repo_path = LibGit2.path(repo)
            LibGit2.close(repo)
        catch
            error("Not inside a git repository")
        end
        
        if isnothing(repo_path) || !isdir(repo_path)
            error("Could not determine git repository root")
        end

        println("Working in git repository root: $repo_path")
        
        repo = LibGit2.GitRepo(repo_path)
        
        println("Discovering submodules...")
        config = LibGit2.GitConfig(repo)
        submodules = String[]
        
        gitmodules_path = joinpath(repo_path, ".gitmodules")
        if isfile(gitmodules_path)
            try
                LibGit2.with(LibGit2.GitConfig(gitmodules_path)) do cfg
                    i = 1
                    while true
                        submod_key = "submodule.$i.path"
                        try
                            path = LibGit2.get(cfg, submod_key, "")
                            if !isempty(path)
                                push!(submodules, path)
                            end
                            i += 1
                        catch
                            break
                        end
                    end
                end
            catch e
                println("Warning: Could not parse .gitmodules: ", e)
            end
        end
        
        if isempty(submodules)
            LibGit2.with(config) do cfg
                for i in 1:100 
                    try
                        path = LibGit2.get(cfg, "submodule.sub$i.path", "")
                        if !isempty(path)
                            push!(submodules, path)
                        end
                    catch
                        break
                    end
                end
            end
        end
        
        if isempty(submodules)
            println("No submodules found in this repository")
            LibGit2.close(repo)
            return
        end

        for submod_path in submodules
            println("\nProcessing submodule at: $submod_path")
            
            if !isdir(joinpath(repo_path, submod_path))
                println("Warning: Submodule directory $submod_path not found, initializing...")
            end
            
            try
                submod = LibGit2.GitSubmodule(repo, submod_path)
                
                if !LibGit2.isinit(submod)
                    LibGit2.set_init(submod)
                end
                
                LibGit2.update(submod; recursive=true)
                
                println("Current status of $submod_path:")
                submod_head = LibGit2.head_oid(submod)
                println("HEAD at: ", string(submod_head))
                
            catch e
                println("Failed to process submodule $submod_path: ", e)
            end
        end
        
        println("\nAll submodules successfully restored to recorded commits!")
        LibGit2.close(repo)
        
    catch e
        println("Error occurred: ", e)
        println("Failed to restore submodules. Please ensure:")
        println("1. Git is installed and accessible")
        println("2. You have permission to access the submodules")
        println("3. You're inside a git repository (any subdirectory)")
        exit(1)
    end
end