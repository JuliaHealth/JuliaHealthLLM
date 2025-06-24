using JuliaHealthLLM
using PromptingTools
using PromptingTools.Experimental.RAGTools: FileChunker, SimpleIndexer
using LibPQ

files = JuliaHealthLLM.collect_files_with_extensions("./data/exp_raw/", [".md", ".txt", ".jl"])
txt_file = write_combined_file(files, "combined_output.txt")

JuliaHealthLLM.register_models("qwen3:0.6b", "nomic-embed-text:v1.5")

cfg = SimpleIndexer()
embedder_kwargs = (schema=PromptingTools.OllamaSchema(), model="nomic-embed-text:v1.5")
index = JuliaHealthLLM.build_index_rag(cfg, files; embedder_kwargs=embedder_kwargs)
println(index)

conn = LibPQ.Connection("host=localhost port=5432 dbname=pgvectordemo user=postgres password=param")

embeddings = index.embeddings
chunks = index.chunks
embedding_dimension = size(embeddings, 1)

embeddings = JuliaHealthLLM.store_embeddings_pgvector(conn, embeddings, chunks, embedding_dimension)

const prompt = """You are expert at developing FunSQL.jl queries. You can write any query using FunSQL.jl given the use case. You can write FunSQL.jl queries accurately and efficiently. Your task is to write FunSQL.jl queries given a question
{input_query}
"""
const question = "Write FunSQL.jl query to find the average age of patients in the dataset"

const response = JuliaHealthLLM.generate_funsql_query(index, "nomic-embed-text:v1.5", "qwen3:0.6b", prompt, question)
println("Generated FunSQL Query: ", response)

