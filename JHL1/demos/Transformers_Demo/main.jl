using Transformers
using Transformers.HuggingFace

# Load the pre-trained model and tokenizer directly
tokenizer, model = hgf"nlpaueb/legal-bert-base-uncased"

println("Model and tokenizer loaded successfully!")