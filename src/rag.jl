const PT = PromptingTools

function load_model_ollama(model_name::String)
    PT.register_model!(name=model_name, schema = PT.OllamaSchema())
end

function load_embedding_ollama(model_name::String)
    PT.register_model!(name=model_name, schema = PT.OllamaSchema())
end

function embed_docs(model_name::String, docs::Vector{String})
    load_embedding_ollama(model_name)
end

function convo(message::String, model_name::String)
    load_model_ollama(model_name)
    msg = aimessage(message, model_name)
    return msg
end