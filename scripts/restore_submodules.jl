function restore_all_submodules()
    try
        # Find the git repository root
        git_root = nothing
        try
            git_root = strip(read(`git rev-parse --show-toplevel`, String))
        catch
            error("Not inside a git repository")
        end
        
        if isempty(git_root) || !isdir(git_root)
            error("Could not determine git repository root")
        end

        # Change to git root directory for operations
        cd(git_root) do
            println("Working in git repository root: $git_root")
            
            # Get list of submodules from git config
            println("Discovering submodules...")
            submodules_output = read(`git submodule status --recursive`, String)
            if isempty(strip(submodules_output))
                println("No submodules found in this repository")
                return
            end

            # Parse submodule paths
            submodule_paths = String[]
            for line in split(submodules_output, '\n')
                if !isempty(strip(line))
                    # Extract path (second field in submodule status output)
                    parts = split(strip(line))
                    if length(parts) >= 2
                        push!(submodule_paths, parts[2])
                    end
                end
            end

            if isempty(submodule_paths)
                println("No active submodules found")
                return
            end

            # Restore each submodule
            for path in submodule_paths
                println("\nProcessing submodule at: $path")
                if !isdir(path)
                    println("Warning: Submodule directory $path not found, initializing...")
                end
                
                # Initialize and update each submodule
                run(`git submodule init $path`)
                run(`git submodule update --recursive $path`)
                
                # Show status for this submodule
                println("Current status of $path:")
                run(`git submodule status $path`)
            end
            
            println("\nAll submodules successfully restored to recorded commits!")
        end
        
    catch e
        println("Error occurred: ", e)
        println("Failed to restore submodules. Please ensure:")
        println("1. Git is installed and accessible")
        println("2. You have permission to access the submodules")
        println("3. You're inside a git repository (any subdirectory)")
        exit(1)
    end
end

# Execute the function if this is the main script
if abspath(PROGRAM_FILE) == @__FILE__
    restore_all_submodules()
end