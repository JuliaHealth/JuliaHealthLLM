function update_and_record_submodules()
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

        output_file = joinpath(repo_path, "submodule_hashes.txt")
        
        repo = LibGit2.GitRepo(repo_path)
        println("Working in git repository root: $repo_path")
        
        config = LibGit2.GitConfig(repo)
        submodules = Dict{String,String}()
        
        println("Discovering submodules...")
        gitmodules_path = joinpath(repo_path, ".gitmodules")
        if isfile(gitmodules_path)
            LibGit2.with(LibGit2.GitConfig(gitmodules_path)) do cfg
                for i in 1:100 
                    try
                        path = LibGit2.get(cfg, "submodule.sub$i.path", "")
                        if !isempty(path)
                            submodules[path] = ""
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

        println("Initializing submodules...")
        println("\nUpdating submodules to latest commits...")
        
        for (submod_path, _) in submodules
            try
                submod = LibGit2.GitSubmodule(repo, submod_path)
                
                if !LibGit2.isinit(submod)
                    LibGit2.set_init(submod)
                end

                LibGit2.update(submod; recursive=true, fetch=true)

                commit_hash = string(LibGit2.head_oid(submod))
                submodules[submod_path] = commit_hash
                
            catch e
                println("Failed to update submodule $submod_path: ", e)
            end
        end

        println("\nRecording submodule states...")
        open(output_file, "w") do io
            println(io, "Submodule Commit Hashes - Recorded on: ", Dates.now())
            println(io, "=========================================")
            
            for (path, commit_hash) in submodules
                if !isempty(commit_hash)
                    println("Recording: $path @ $commit_hash")
                    println(io, "Path: $path")
                    println(io, "Commit: $commit_hash")
                    println(io, "")
                end
            end
        end

        println("\nChecking for changes to commit...")
        status = LibGit2.status(repo)
        
        if !isempty(status)
            println("Committing submodule updates...")
            idx = LibGit2.GitIndex(repo)
            LibGit2.add!(idx, ".gitmodules")
            LibGit2.add!(idx, "submodule_hashes.txt")
            LibGit2.write!(idx)

            tree_id = LibGit2.write_tree!(idx)
            parents = LibGit2.isdetached(repo) ? [] : [LibGit2.head_oid(repo)]
            sig = LibGit2.default_signature(repo)
            LibGit2.commit(repo, "Updated submodules to latest commits and recorded hashes";
                          tree=tree_id, parents=parents, author=sig, committer=sig)
            println("Changes committed successfully")
        else
            println("No changes to commit - submodules were already up to date")
        end
        
        println("\nSubmodule updates completed!")
        println("Hashes recorded in: $output_file")
        println("Current status:")
        for (submod_path, commit_hash) in submodules
            if !isempty(commit_hash)
                println("$submod_path $commit_hash")
            end
        end
        
        LibGit2.close(repo)
        
    catch e
        println("Error occurred: ", e)
        println("Failed to update submodules. Please ensure:")
        println("1. Git is installed and accessible")
        println("2. You have permission to access and modify the submodules")
        println("3. You're inside a git repository")
        println("4. You have push access to the remote repositories")
        exit(1)
    end
end