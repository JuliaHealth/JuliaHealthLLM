using LibGit2
using TextAnalysis
using Serialization

function normalize_repo_url(input::String)
    if occursin(r"^https?://", input)
        return endswith(input, ".git") ? input : input * ".git"
    elseif occursin(r"^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$", input)
        return "https://github.com/$input.git"
    else
        error("Invalid repository URL or name: $input. Use 'owner/repo' or a full Git URL (e.g., 'https://github.com/owner/repo.git').")
    end
end

function clone_repo(repo_url::String, local_path::String)
    println("Cloning repository from $repo_url to $local_path...")
    LibGit2.clone(repo_url, local_path)
    println("Repository cloned successfully.")
end

function is_textual_file(filename::String)
    textual_extensions = r"\.(md|jl|txt|rst|doc|docx|py|cpp|c|h|java|sh)$"
    return occursin(textual_extensions, lowercase(filename))
end

function build_corpus_from_repo(repo_input::String)
    repo_url = normalize_repo_url(repo_input)
    repo_name = split(repo_url, "/")[end] |> x -> replace(x, ".git" => "")
    local_path = joinpath(pwd(), "repo_$repo_name")
    
    if isdir(local_path)
        println("Directory $local_path already exists, reusing it.")
    else
        clone_repo(repo_url, local_path)
    end
    
    documents = AbstractDocument[]
    
    function process_directory(dir_path)
        for entry in readdir(dir_path, join=true)
            if isfile(entry) && is_textual_file(entry)
                println("Processing file: $entry")
                content = read(entry, String)
                doc = StringDocument(content)
                push!(documents, doc)
            elseif isdir(entry) && !occursin(r"^\.", basename(entry))
                println("Exploring directory: $entry...")
                process_directory(entry)
            end
        end
    end
    
    process_directory(local_path)
    
    corpus = Corpus(documents)
    println("Updating corpus lexicon and index...")
    update_lexicon!(corpus)
    update_inverse_index!(corpus)
    
    return corpus
end

function analyze_corpus(corpus::Corpus)
    println("\nCorpus Analysis:")
    println("Number of documents: ", length(corpus))
    println("Lexicon size: ", length(lexicon(corpus)))
    
    words_of_interest = ["julia", "function", "type", "performance"]
    println("\nWord frequencies:")
    for word in words_of_interest
        freq = lexical_frequency(corpus, word)
        println("$word: $freq")
    end
    
    search_word = "julia"
    doc_indices = corpus[search_word]
    println("\nDocuments containing '$search_word': ", length(doc_indices))
end

function save_corpus(corpus::Corpus, repo_input::String)
    current_dir = pwd()
    safe_repo_name = split(normalize_repo_url(repo_input), "/")[end] |> x -> replace(x, ".git" => "") |> x -> replace(x, r"[^a-zA-Z0-9_]" => "_")
    filename = joinpath(current_dir, "corpus_$(safe_repo_name).jls")
    
    println("Saving corpus to $filename...")
    open(filename, "w") do io
        serialize(io, corpus)
    end
    println("Corpus saved successfully.")
end

function main()
    repo_input = ""
    
    if isinteractive()
        println("Please enter the GitHub repository URL or name (e.g., 'https://github.com/JuliaLang/julia.git' or 'JuliaLang/julia'):")
        repo_input = readline()
    else
        if length(ARGS) > 0
            repo_input = ARGS[1]
            println("Using repository from command-line argument: $repo_input")
        else
            repo_input = "https://github.com/JuliaLang/julia.git"
            println("No repository specified. Using default: $repo_input")
        end
    end
    
    if isempty(strip(repo_input))
        println("Error: Repository input cannot be empty. Using default 'https://github.com/JuliaLang/julia.git'.")
        repo_input = "https://github.com/JuliaLang/julia.git"
    else
        println("Using repository: $repo_input")
    end
    
    try
        corpus = build_corpus_from_repo(repo_input)
        analyze_corpus(corpus)
        save_corpus(corpus, repo_input)
        return corpus
    catch e
        println("Error occurred: $e")
        println("Please check the repository URL or name and ensure it is valid.")
        return nothing
    end
end

corpus = main()