module JuliaHealthLLM

using PromptingTools
using PromptingTools.Experimental.RAGTools
using LinearAlgebra, SparseArrays
using JSON3, Serialization
using Statistics
using LibPQ

include("utils.jl")
include("pgvector.jl")
include("database.jl")
include("embedding.jl")
include("query.jl")

export collect_files_with_extensions, write_combined_file, generate_funsql_query,
build_index_rag, store_embeddings_pgvector

end