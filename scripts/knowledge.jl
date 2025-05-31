"""
    normalize_repo_url(input::String) -> String

Normalizes a repository URL or name into a full GitHub URL.

# Arguments
- `input::String`: The repository name (e.g., "owner/repo") or a full Git URL.

# Returns
- A normalized GitHub URL ending with `.git`.

# Throws
- An error if the input is not a valid repository name or URL.

# Behavior
- If the input is already a valid Git URL (e.g., "https://github.com/owner/repo.git"), it is returned as-is.
- If the input is a repository name in the format "owner/repo", it is converted to a full GitHub URL.
- If the input is invalid, an error is raised.

# Example
```julia
normalize_repo_url("JuliaLang/julia") # "https://github.com/JuliaLang/julia.git"
normalize_repo_url("https://github.com/JuliaLang/julia") # "https://github.com/JuliaLang/julia.git"
normalize_repo_url("invalid_repo") # Error: Invalid repository URL or name
```
"""
function normalize_repo_url(input::String)
    if occursin(r"^https?://", input)
        return endswith(input, ".git") ? input : input * ".git"
    elseif occursin(r"^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$", input)
        return "https://github.com/$input.git"
    else
        error("Invalid repository URL or name: $input. Use 'owner/repo' or a full Git URL (e.g., 'https://github.com/owner/repo.git').")
    end
end

"""
    clone_repo(repo_url::String, local_path::String)

Clones a Git repository to a specified local path.

# Arguments
- `repo_url::String`: The URL of the repository to clone.
- `local_path::String`: The local directory where the repository will be cloned.

# Behavior
- If the cloning is successful, the repository is cloned to the specified path.
- Prints progress messages during the cloning process.

# Throws
- An error if the cloning process fails (e.g., invalid URL, network issues, or permission errors).

# Example
```julia
clone_repo("https://github.com/JuliaLang/julia.git", "local_julia_repo")
```
"""
function clone_repo(repo_url::String, local_path::String)
    println("Cloning repository from $repo_url to $local_path...")
    LibGit2.clone(repo_url, local_path)
    println("Repository cloned successfully.")
end

"""
    is_textual_file(filename::String) -> Bool

Checks if a file is a textual file based on its extension.

# Arguments
- `filename::String`: The name of the file to check.

# Returns
- `true` if the file has a textual extension (e.g., `.md`, `.jl`, `.txt`, etc.), otherwise `false`.

# Behavior
- The function uses a regular expression to match common textual file extensions.
- The check is case-insensitive.

# Example
```julia
is_textual_file("README.md") # true
is_textual_file("script.jl") # true
is_textual_file("image.png") # false
```
"""
function is_textual_file(filename::String)
    textual_extensions = r"\.(md|jl|txt|rst|doc|docx|py|cpp|c|h|java|sh)$"
    return occursin(textual_extensions, lowercase(filename))
end

"""
    process_directory(dir_path::String, documents::Vector{AbstractDocument})

Recursively processes a directory to extract textual files and add them to a document collection.

# Arguments
- `dir_path::String`: The directory to process.
- `documents::Vector{AbstractDocument}`: A vector to store the extracted documents.

# Behavior
- Textual files are identified using the `is_textual_file` function.
- The content of each textual file is read and converted into a `StringDocument` object, which is added to the `documents` vector.
- Subdirectories are explored recursively, skipping hidden directories (those starting with a dot).

# Example
```julia
documents = AbstractDocument[]
process_directory("path/to/repo", documents)
println("Number of documents processed: ", length(documents))
```
"""
function process_directory(dir_path::String, documents::Vector{AbstractDocument})
    for entry in readdir(dir_path, join=true)
        if isfile(entry) && is_textual_file(entry)
            println("Processing file: $entry")
            content = read(entry, String)
            doc = StringDocument(content)
            push!(documents, doc)
        elseif isdir(entry) && !occursin(r"^\.", basename(entry))
            println("Exploring directory: $entry...")
            process_directory(entry, documents)  # Recursive call
        end
    end
end

"""
    build_corpus_from_repo(repo_input::String) -> Corpus

Clones a repository (if not already cloned), processes its files, and builds a corpus.

# Arguments
- `repo_input::String`: The repository name (e.g., "owner/repo") or a full Git URL.

# Returns
- A `Corpus` object containing the textual content of the repository.

# Behavior
- The repository URL is normalized using `normalize_repo_url`.
- If the repository is already cloned, it reuses the local copy; otherwise, it clones the repository using `clone_repo`.
- The repository's directory is processed recursively using `process_directory` to extract textual files.
- A `Corpus` object is created from the extracted documents, and its lexicon and index are updated.

# Example
```julia
corpus = build_corpus_from_repo("JuliaLang/julia")
println("Corpus contains ", length(corpus), " documents.")
```
"""
function build_corpus_from_repo(repo_input::String)::Corpus
    repo_url = normalize_repo_url(repo_input)
    repo_name = split(repo_url, "/")[end] |> x -> replace(x, ".git" => "")
    local_path = joinpath(pwd(), "repo_$repo_name")
    
    if isdir(local_path)
        println("Directory $local_path already exists, reusing it.")
    else
        clone_repo(repo_url, local_path)
    end
    
    documents = AbstractDocument[]
    process_directory(local_path, documents)  # Call the standalone function
    
    corpus = Corpus(documents)
    println("Updating corpus lexicon and index...")
    update_lexicon!(corpus)
    update_inverse_index!(corpus)
    
    return corpus
end

"""
    save_corpus(corpus::Corpus, repo_input::String)

Saves a corpus to a file in the current working directory.

# Arguments
- `corpus::Corpus`: The corpus to save.
- `repo_input::String`: The repository name or URL (used to generate the filename).

# Behavior
- The repository name is normalized using `normalize_repo_url` to create a safe filename.
- The corpus is serialized and saved to a `.jls` file in the current working directory.
- Ensures the target directory exists before saving the file.
- Prints progress messages during the saving process.

# Throws
- An error message is printed if the saving process fails (e.g., permission issues or invalid paths).

# Example
```julia
corpus = build_corpus_from_repo("JuliaLang/julia")
save_corpus(corpus, "JuliaLang/julia")
```
"""
function save_corpus(corpus::Corpus, repo_input::String)
    current_dir = pwd()
    safe_repo_name = split(normalize_repo_url(repo_input), "/")[end] |> 
                     x -> replace(x, ".git" => "") |> 
                     x -> replace(x, r"[^a-zA-Z0-9_]" => "_")
    filename = joinpath(current_dir, "corpus_$(safe_repo_name).jls")
    
    try
        println("Saving corpus to $filename...")
        
        # Ensure the directory exists
        dir_path = dirname(filename)
        if !isdir(dir_path)
            println("Directory $dir_path does not exist. Creating it...")
            mkdir(dir_path)
        end
        
        # Save the corpus to the file
        open(filename, "w") do io
            serialize(io, corpus)
        end
        
        println("Corpus saved successfully to $filename.")
    catch e
        println("Failed to save corpus: $e")
    end
end