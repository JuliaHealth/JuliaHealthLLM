module Utils

function collect_files_with_extensions(directory::String, extensions::Vector{String})
    files = String[]
    for (root, _, file_names) in walkdir(directory)
        for file_name in file_names
            if any(endswith(file_name, ext) for ext in extensions)
                relative_path = joinpath(relpath(root, directory), file_name)
                push!(files, relative_path)
            end
        end
    end
    return files
end

function write_combined_file(files::Vector{String}, output_file::String)
    open(output_file, "w") do io
        for file in files
            println(io, "# File: $file")
            open(file, "r") do f
                for line in eachline(f)
                    println(io, line)
                end
            end
            println(io, "\n")
        end
    end
end

end