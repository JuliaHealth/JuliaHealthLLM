module JuliaHealthLLM

using PromptingTools
using PromptingTools.Experimental.RAGTools
using LinearAlgebra, SparseArrays
using JSON3, Serialization
using Statistics

include("utils.jl")
include("pgvector.jl")
include("database.jl")
include("embedding.jl")
include("query.jl")

import .Utils: collect_files_with_extensions, write_combined_file, register_models
import .Embedding: build_index_rag
import .Database: store_embeddings_pgvector
import .Query: generate_funsql_query

export collect_files_with_extensions, write_combined_file, generate_funsql_query,
build_index_rag, store_embeddings_pgvector

end