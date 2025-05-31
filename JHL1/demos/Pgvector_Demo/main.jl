using LibPQ
using Tables
using DataFrames

# Function to establish database connection
function get_db_connection()
    return LibPQ.Connection("host=localhost port=5432 dbname=pgvectordemo user=postgres password=param")
end

# Function to create table with vector column
function setup_database()
    conn = get_db_connection()
    try
        # Enable the pgvector extension
        execute(conn, """
            CREATE EXTENSION IF NOT EXISTS vector;
        """)

        # Create table with vector column (assuming 384 dimensions for embeddings)
        execute(
            conn,
            """
            CREATE TABLE IF NOT EXISTS sentences (
                id SERIAL PRIMARY KEY,
                text TEXT NOT NULL,
                embedding VECTOR(384)
            )
            """
        )

        # Create index for faster similarity search
        execute(
            conn,
            """
            CREATE INDEX IF NOT EXISTS sentences_embedding_idx 
            ON sentences USING ivfflat (embedding vector_cosine_ops)
            WITH (lists = 100)
            """
        )
    finally
        close(conn)
    end
end

# Function to generate dummy embedding (in real case, use a model like BERT)
function generate_embedding(text::String)
    # This is a placeholder - in practice, use a proper embedding model
    return rand(Float32, 384)
end

# Function to insert a sentence with its embedding
function insert_sentence(text::String)
    conn = get_db_connection()
    try
        embedding = generate_embedding(text)
        embedding_str = "[" * join(embedding, ",") * "]"

        result = execute(conn, """
            INSERT INTO sentences (text, embedding)
            VALUES (\$1, \$2::vector)
            RETURNING id
        """, [text, embedding_str])

        # Fetch the result using collect and get the first row's id
        rows = collect(result)
        return rows[1][1]  # Returns Int32 from SERIAL
    finally
        close(conn)
    end
end

# Function to find similar sentences using cosine similarity
function find_similar_sentences(query_text::String, limit::Int = 5)
    conn = get_db_connection()
    try
        query_embedding = generate_embedding(query_text)
        embedding_str = "[" * join(query_embedding, ",") * "]"

        result = execute(conn, """
            SELECT id, text, 
                   1 - (embedding <=> \$1::vector) AS similarity
            FROM sentences
            ORDER BY embedding <=> \$1::vector
            LIMIT \$2
        """, [embedding_str, limit])

        # Convert the result to a DataFrame using Tables.columntable
        return DataFrame(Tables.columntable(result))
    finally
        close(conn)
    end
end

# Function to update sentence text (changed to accept Int32)
function update_sentence(id::Int32, new_text::String)
    conn = get_db_connection()
    try
        new_embedding = generate_embedding(new_text)
        embedding_str = "[" * join(new_embedding, ",") * "]"

        execute(conn, """
            UPDATE sentences 
            SET text = \$1,
                embedding = \$2::vector
            WHERE id = \$3
        """, [new_text, embedding_str, id])
    finally
        close(conn)
    end
end

# Function to delete a sentence (changed to accept Int32)
function delete_sentence(id::Int32)
    conn = get_db_connection()
    try
        execute(conn, """
            DELETE FROM sentences 
            WHERE id = \$1
        """, [id])
    finally
        close(conn)
    end
end

# Main execution
setup_database()

# Insert some example sentences
sentences = [
    "The quick brown fox jumps over the lazy dog",
    "A fast brown fox leaps over a idle dog",
    "The cat sits on the mat",
    "Rain falls gently on the roof",
]

println("Inserting sentences...")
ids = [insert_sentence(s) for s in sentences]

# Find similar sentences
query = "A swift fox jumps over a resting dog"
println("\nFinding similar sentences to: '$query'")
similar_df = find_similar_sentences(query)
println(similar_df)

# Update a sentence
println("\nUpdating sentence with id=$(ids[1])")
update_sentence(ids[1], "The speedy brown fox hops over the idle dog")

# Show updated results
println("\nFinding similar sentences after update:")
similar_df = find_similar_sentences(query)
println(similar_df)

# Delete a sentence
println("\nDeleting sentence with id=$(ids[3])")
delete_sentence(ids[3])