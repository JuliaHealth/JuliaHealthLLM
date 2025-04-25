using LinearAlgebra, SparseArrays
using PromptingTools
using PromptingTools.Experimental.RAGTools: FileChunker, build_index, SimpleIndexer, airag
using JSON3, Serialization
using Statistics: mean
const PT = PromptingTools
const RT = PromptingTools.Experimental.RAGTools

# Register models with Ollama schema
PT.register_model!(name="deepseek-r1:1.5b", schema=PT.OllamaSchema())
PT.register_model!(name="nomic-embed-text:latest", schema=PT.OllamaSchema())

# Function to collect files with specified extensions
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

# Function to combine files into a single output file
function write_combined_file(files::Vector{String}, output_file::String)
    open(output_file, "w") do io
        for file in files
            println(io, "# File: $file")
            open(file, "r") do f
                for line in eachline(f)
                    println(io, line)
                end
            end
            println(io, "\n")  # Add a separator between files
        end
    end
end

# Define directory, extensions, and output file
directory = "."
extensions = [".jl", ".md", ".Rmd"]
output_file = "combined_output.txt"

# Collect files and create combined output
files = collect_files_with_extensions(directory, extensions)
write_combined_file(files, output_file)

# Build index with explicit Ollama schema for embeddings
cfg = SimpleIndexer(chunker=FileChunker())
index = build_index(cfg, [output_file]; embedder_kwargs = (schema = PT.OllamaSchema(), model = "nomic-embed-text:latest"))
println("Index built with $(length(index)) chunks.")

# Perform RAG query with explicit embedder_kwargs in retriever_kwargs
answer = airag(index; 
    question = "Write a FunSQL.jl query to find all male patients in the database?",
    retriever_kwargs = (model = "nomic-embed-text:latest", schema = PT.OllamaSchema(), embedder_kwargs = (schema = PT.OllamaSchema(), model = "nomic-embed-text:latest")),
    generator_kwargs = (model = "deepseek-r1:1.5b", schema = PT.OllamaSchema())
)
println(answer)