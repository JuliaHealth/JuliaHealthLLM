struct TextChunk
    content::SubString{String}
    metadata::Dict{String, Any}
end

function chunk_file_content(filepath::String, content::String=""; 
                          chunk_size::Int=1000, chunk_overlap::Int=200)
    try
        ext = lowercase(splitext(filepath)[2])
        
        if isempty(content)
            if !isfile(filepath)
                @warn "File not found: $filepath"
                return TextChunk[]
            end
            content = open(filepath, "r") do io
                read(io, String)
            end
        end

        processed_content = if ext == ".md"
            md = Markdown.parse(content)
            sprint(write, MIME("text/plain"), md, context=IOBuffer())
        elseif ext == ".html"
            replace(content, r"<[^>]+>|\s+" => " ")
        elseif ext == ".json"
            json_data = JSON.parse(content)
            JSON.json(json_data)
        else
            return TextChunk[]
        end

        content = strip(processed_content)
        if isempty(content)
            return TextChunk[]
        end

        content_length = length(content)
        n_chunks = cld(content_length, chunk_size - chunk_overlap)
        chunks = Vector{TextChunk}(undef, n_chunks)
        chunk_idx = 1

        start_pos = 1
        while start_pos <= content_length && chunk_idx <= n_chunks
            end_pos = min(start_pos + chunk_size - 1, content_length)
            chunk_text = SubString(content, start_pos, end_pos)
            
            metadata = Dict{String, Any}(
                "source" => filepath,
                "start_index" => start_pos,
                "end_index" => end_pos
            )
            
            chunks[chunk_idx] = TextChunk(chunk_text, metadata)
            chunk_idx += 1
            start_pos = end_pos - chunk_overlap + 1
        end

        return resize!(chunks, chunk_idx - 1)
    catch e
        @warn "Error processing file $filepath: $e"
        return TextChunk[]
    end
end

function traverse_repository(root_dir::String; 
                           chunk_size::Int=1000, 
                           chunk_overlap::Int=200)
    if chunk_size <= 0 || chunk_overlap < 0 || chunk_overlap >= chunk_size
        throw(ArgumentError("Invalid chunk parameters"))
    end

    if !isdir(root_dir)
        throw(ArgumentError("Directory not found: $root_dir"))
    end

    valid_extensions = Set([".md", ".html", ".json"])
    files = String[]
    
    for (root, _, fs) in walkdir(root_dir)
        for file in fs
            if lowercase(splitext(file)[2]) in valid_extensions
                push!(files, joinpath(root, file))
            end
        end
    end

    n_files = length(files)
    all_chunks = Vector{Vector{TextChunk}}(undef, n_files)
    errors = Channel{Tuple{Int,String}}(n_files)
    
    @sync begin
        for i in 1:n_files
            @async begin
                filepath = files[i]
                try
                    @debug "Processing: $filepath"
                    all_chunks[i] = chunk_file_content(filepath, 
                                                     chunk_size=chunk_size, 
                                                     chunk_overlap=chunk_overlap)
                catch e
                    put!(errors, (i, "Error in $filepath: $e"))
                    all_chunks[i] = TextChunk[]
                end
            end
        end
    end

    while isready(errors)
        idx, err = take!(errors)
        @warn "Task $idx failed: $err"
    end

    return reduce(vcat, all_chunks)
end