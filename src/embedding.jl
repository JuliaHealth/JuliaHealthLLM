module Embedding

using PromptingTools
function build_index_rag(cfg, files; embedder_kwargs=())
    return PromptingTools.Experimental.RAGTools.build_index(cfg, files; embedder_kwargs=embedder_kwargs)
end

end