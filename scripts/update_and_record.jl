using Dates

function update_and_record_submodules()
    try
        git_root = nothing
        try
            git_root = strip(read(`git rev-parse --show-toplevel`, String))
        catch
            error("Not inside a git repository")
        end
        
        if isempty(git_root) || !isdir(git_root)
            error("Could not determine git repository root")
        end

        output_file = joinpath(git_root, "submodule_hashes.txt")
        
        cd(git_root) do
            println("Working in git repository root: $git_root")
            
            println("Initializing submodules...")
            run(`git submodule init`)
            
            println("\nUpdating submodules to latest commits...")
            run(`git submodule update --remote --recursive`)
            
            println("\nRecording submodule states...")
            submodules_output = read(`git submodule status --recursive`, String)
            if isempty(strip(submodules_output))
                println("No submodules found in this repository")
                return
            end

            open(output_file, "w") do io
                println(io, "Submodule Commit Hashes - Recorded on: ", Dates.now())
                println(io, "=========================================")
                
                for line in split(submodules_output, '\n')
                    if !isempty(strip(line))
                        parts = split(strip(line))
                        if length(parts) >= 2
                            commit_hash = parts[1]
                            commit_hash = replace(commit_hash, r"^[+-]" => "")
                            path = parts[2]
                            
                            println("Recording: $path @ $commit_hash")
                            println(io, "Path: $path")
                            println(io, "Commit: $commit_hash")
                            println(io, "")
                        end
                    end
                end
            end
            
            println("\nChecking for changes to commit...")
            status_output = read(`git status --porcelain`, String)
            
            if !isempty(strip(status_output))
                println("Committing submodule updates...")
                run(`git add .gitmodules`)
                run(`git add $output_file`)
                run(`git commit -m "Updated submodules to latest commits and recorded hashes"`)
                println("Changes committed successfully")
            else
                println("No changes to commit - submodules were already up to date")
            end
            
            println("\nSubmodule updates completed!")
            println("Hashes recorded in: $output_file")
            println("Current status:")
            run(`git submodule status --recursive`)
        end
        
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

if abspath(PROGRAM_FILE) == @__FILE__
    update_and_record_submodules()
end