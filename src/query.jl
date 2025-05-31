module Query

function generate_funsql_query(index, model_embedding::String, model_name::String, prompt_template::String, question::String)
    PromptingTools.MODEL_CHAT = model_name
    PromptingTools.MODEL_EMBEDDING = model_embedding

    PT.register_model!(name=MODEL_CHAT, schema=PT.OllamaSchema())
    PT.register_model!(name=MODEL_EMBEDDING, schema=PT.OllamaSchema())
    
    prompt = replace(prompt_template, "{input_query}" => question)

    answer = airag(index; 
        question=prompt,
        retriever_kwargs=(model=model_embedding, schema=PT.OllamaSchema(), embedder_kwargs=(schema=PT.OllamaSchema(), model=MODEL_EMBEDDING)),
        generator_kwargs=(model=model_name, schema=PT.OllamaSchema())
    )

    return answer
end

end