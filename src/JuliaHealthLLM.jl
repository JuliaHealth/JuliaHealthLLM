module JuliaHealthLLM

using LibGit2
using Downloads
using Dates
using TextAnalysis
using Serialization

# TODO: Add functions from scripts
include("../scripts/clone.jl")
include("../scripts/knowledge.jl")
include("../scripts/restore_submodules.jl")
include("../scripts/update_julia_package_repos.jl")
include("../scripts/update_and_record.jl")

export clone_repositories, normalize_repo_url, clone_repo, is_textual_file,
       build_corpus_from_repo, save_corpus, process_directory, update_and_record_submodules,
       restore_all_submodules, update_julia_package_repos

end