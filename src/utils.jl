module Utils

using PromptingTools

function collect_files_with_extensions(directory::String, extensions::Vector{String})
    files = String[]
    for (root, _, file_names) in walkdir(directory)
        for file_name in file_names
            if any(endswith(file_name, ext) for ext in extensions)
                full_path = joinpath(root, file_name)
                push!(files, full_path)
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
    return output_file
end

function register_models(model_name::String, model_embedding::String)
    PromptingTools.register_model!(name=model_name, schema=PromptingTools.OllamaSchema())
    PromptingTools.register_model!(name=model_embedding, schema=PromptingTools.OllamaSchema())

    PromptingTools.MODEL_CHAT = model_name
    PromptingTools.MODEL_EMBEDDING = model_embedding
end

end