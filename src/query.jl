module Query

using PromptingTools
using PromptingTools.Experimental.RAGTools

function generate_funsql_query(index, model_embedding::String, model_name::String, prompt_template::String, question::String)
    prompt = replace(prompt_template, "{input_query}" => question)

    answer = PromptingTools.Experimental.RAGTools.airag(index; 
        question=prompt,
        retriever_kwargs=(model=model_embedding, schema=PromptingTools.OllamaSchema(), embedder_kwargs=(schema=PromptingTools.OllamaSchema(), model=model_embedding)),
        generator_kwargs=(model=model_name, schema=PromptingTools.OllamaSchema())
    )

    return answer
end

end