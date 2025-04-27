using LinearAlgebra, SparseArrays
using PromptingTools
using PromptingTools.Experimental.RAGTools: FileChunker, build_index, SimpleIndexer, airag
using JSON3, Serialization
using Statistics: mean
using LibPQ

const PT = PromptingTools
const RT = PromptingTools.Experimental.RAGTools

# User-defined models
MODEL_CHAT = "deepseek-r1:1.5b"  # Default chat model
MODEL_EMBEDDING = "nomic-embed-text:latest"  # Default embedding model

# Overwrite package globals with user-defined models
PromptingTools.MODEL_CHAT = MODEL_CHAT
PromptingTools.MODEL_EMBEDDING = MODEL_EMBEDDING

# Register models with Ollama schema
PT.register_model!(name=MODEL_CHAT, schema=PT.OllamaSchema())
PT.register_model!(name=MODEL_EMBEDDING, schema=PT.OllamaSchema())

# Pgvector conversion module
module Pgvector
    convert(v::AbstractVector{T}) where T<:Real = string("[", join(v, ","), "]")
end

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

# Prompt template for FunSQL.jl query generation
const FUNSQL_PROMPT_TEMPLATE = """
You are an expert in FunSQL.jl, a Julia library for compositional construction of SQL queries. Your task is to translate the given natural language question into a corresponding FunSQL.jl query. Provide only the FunSQL.jl query as output, without any additional text or explanation.

For example:
Question: "Find all male patients in the database."
FunSQL.jl Query: From(:person) |> Where(Get.gender .== "M") |> Select(Get.person_id)

Now, for the following question, generate only the FunSQL.jl query:

Question: {input_query}

FunSQL.jl Query:
"""

# Define directory, extensions, and output file
directory = "."
extensions = [".jl", ".md", ".Rmd"]
output_file = "combined_output.txt"

# Collect and combine files
files = collect_files_with_extensions(directory, extensions)
write_combined_file(files, output_file)

# Database connection
conn = LibPQ.Connection("host=localhost port=5432 dbname=pgvectordemo user=postgres password=param")

# Build index with user-defined embedding model
cfg = SimpleIndexer(chunker=FileChunker())
index = build_index(cfg, [output_file]; embedder_kwargs=(schema=PT.OllamaSchema(), model=MODEL_EMBEDDING))
println("Index built with $(length(index)) chunks.")

# Function to store embeddings in a PostgreSQL database using pgvector
function store_embeddings_in_pgvector(conn::LibPQ.Connection, embeddings::AbstractMatrix, chunks::AbstractVector, embedding_dimension::Int)
    # Ensure the table exists
    LibPQ.execute(conn, """
        CREATE TABLE IF NOT EXISTS embeddings (
            id SERIAL PRIMARY KEY,
            chunk TEXT NOT NULL,
            embedding VECTOR($embedding_dimension)
        )
    """)

    # Convert embeddings to Float64 if necessary
    embeddings = convert(Matrix{Float64}, embeddings)

    # Convert chunks to Vector{String} if necessary
    chunks = String.(chunks)

    # Insert embeddings and their corresponding chunks
    for i in 1:size(embeddings, 2)
        chunk = chunks[i]
        embedding = Pgvector.convert(embeddings[:, i])
        LibPQ.execute(conn, """
            INSERT INTO embeddings (chunk, embedding)
            VALUES (\$1, \$2)
        """, (chunk, embedding))  # Pass parameters as a tuple
    end

    println("Embeddings successfully stored in the database.")
end

# Assuming the embedding model produces 768-dimensional embeddings
embedding_dimension = 768  # Adjust based on actual model output
store_embeddings_in_pgvector(conn, index.embeddings, index.chunks, embedding_dimension)

# Function to generate FunSQL.jl query using the prompt template
function generate_funsql_query(index, question::String)
    # Fill the prompt template with the user's question
    prompt = replace(FUNSQL_PROMPT_TEMPLATE, "{input_query}" => question)
    
    # Perform RAG query with the filled prompt
    answer = airag(index; 
        question=prompt,
        retriever_kwargs=(model=MODEL_EMBEDDING, schema=PT.OllamaSchema(), embedder_kwargs=(schema=PT.OllamaSchema(), model=MODEL_EMBEDDING)),
        generator_kwargs=(model=MODEL_CHAT, schema=PT.OllamaSchema())
    )
    return answer
end

question = "Write a FunSQL.jl query to find all male patients in the database?"
answer = generate_funsql_query(index, question)
println("Generated FunSQL.jl Query: $answer")