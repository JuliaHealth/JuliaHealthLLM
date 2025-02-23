using Dates

function update_julia_package_repos()
    try
        repo_list = Dict(
            "General" => "https://github.com/JuliaRegistries/General.git",
            "Julia" => "https://github.com/JuliaLang/julia.git",
            "Pkg" => "https://github.com/JuliaLang/Pkg.jl.git"
        )
        
        base_dir = "./data/exp_raw"
        
        git_root = nothing
        try
            git_root = strip(read(`git rev-parse --show-toplevel`, String))
        catch
            # If not in a git repo, initialize one
            println("Not in a git repository, initializing new one...")
            run(`git init`)
            git_root = pwd()
        end
        
        if isempty(git_root) || !isdir(git_root)
            error("Could not determine or create git repository root")
        end

        cd(git_root) do
            println("Working in directory: $git_root")
            
            if !isdir(base_dir)
                mkpath(base_dir)
                println("Created directory: $base_dir")
            end

            cd(base_dir) do
                for (name, url) in repo_list
                    repo_dir = name
                    
                    if isdir(repo_dir)
                        println("\nUpdating existing repository: $name")
                        cd(repo_dir) do
                            run(`git fetch origin`)
                            run(`git reset --hard origin/master`)
                            println("Updated $name to latest master")
                        end
                    else
                        println("\nCloning new repository: $name")
                        run(`git clone $url $repo_dir`)
                        println("Cloned $name successfully")
                    end
                end
            end
            
            output_file = "julia_repos_status.txt"
            open(output_file, "w") do io
                println(io, "Julia Package Repositories Status - Updated on: ", Dates.now())
                println(io, "=========================================")
                
                cd(base_dir) do
                    for name in keys(repo_list)
                        cd(name) do
                            commit_hash = strip(read(`git rev-parse HEAD`, String))
                            println(io, "Repository: $name")
                            println(io, "Commit: $commit_hash")
                            println(io, "")
                            println("Recorded status for $name: $commit_hash")
                        end
                    end
                end
            end
            
            println("\nChecking for changes to commit...")
            status_output = read(`git status --porcelain`, String)
            
            if !isempty(strip(status_output))
                println("Committing changes...")
                run(`git add $base_dir`)
                run(`git add $output_file`)
                run(`git commit -m "Updated Julia package reference repositories in data/exp_raw - $(Dates.now())"`)
                println("Changes committed successfully")
            else
                println("No changes to commit - repositories were already up to date")
            end
            
            println("\nProcess completed!")
            println("Repository status recorded in: $output_file")
            println("Current git status:")
            run(`git status`)
        end
        
    catch e
        println("Error occurred: ", e)
        println("Failed to update Julia package repositories. Please ensure:")
        println("1. Git is installed and accessible")
        println("2. You have write permissions in the current directory")
        println("3. You have internet access to clone/pull from GitHub")
        exit(1)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    update_julia_package_repos()
end