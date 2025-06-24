module Database
using LibPQ
using ..Pgvector: convert
import Base: convert

function store_embeddings_pgvector(conn::LibPQ.Connection, embeddings::AbstractMatrix, chunks::AbstractVector, embedding_dimension::Int)
    LibPQ.execute(conn, """
        CREATE TABLE IF NOT EXISTS embeddings (
            id SERIAL PRIMARY KEY,
            chunk TEXT NOT NULL,
            embedding VECTOR($embedding_dimension)
        )
    """)

    embeddings = Base.convert(Matrix{Float64}, embeddings)
    chunks = String.(chunks)

    for i in 1:size(embeddings, 2)
        chunk = chunks[i]
        embedding = convert(embeddings[:, i])
        LibPQ.execute(conn, """
            INSERT INTO embeddings (chunk, embedding)
            VALUES (\$1, \$2)
        """, (chunk, embedding))
    end

    println("Embeddings successfully stored in the database.")
end

end