#=

Instructions:

1. You must have ollama installed on your computer https://github.com/ollama/ollama and accessible to Julia from your path

2. Install a model of your choice to ollama (I installed so I will use that in the demo llama3.1)

3. Start ollama in a separate session using `ollama serve`

4. Then continue with the Julia tutorial

=#

using PromptingTools

const PT = PromptingTools
schema = PT.OllamaSchema()

prompt = 
    """
    Give me a three ideas (each 3 sentences long) for an observational health research study using data found within the OMOP CDM.
    """

msg = aigenerate(schema, prompt; model = "llama3.1")

#=

Here is an example output from the previous command; note that length of time will vary depending on your hardware.

[ Info: Tokens: 427 in 76.8 seconds
AIMessage("Here are three potential ideas for observational health research studies using data from the Observational Medical Outcomes Partnership Common Data Model (OMOP CDM):

**Idea 1: Association between medication adherence and risk of hospitalization due to falls in older adults** This study would aim to investigate the relationship between medication non-adherence and the incidence of fall-related hospitalizations among individuals aged 65 and above. Using OMOP CDM data, researchers could extract a cohort of elderly patients with a history of falls or medication non-adherence, and analyze the hazard ratio of hospitalization due to falls among those with poor adherence versus good adherence. The findings from this study could inform strategies for improving medication adherence and reducing fall-related morbidity in older adults.

**Idea 2: Comparative effectiveness of different antidepressant medications in patients with treatment-resistant depression**This research would compare the efficacy and safety of various antidepressant medications in a cohort of patients who have not responded to previous treatments. By querying the OMOP CDM, researchers could identify patients with treatment-resistant depression and assess outcomes following initiation of different antidepressant therapies (e.g., SSRIs, SNRIs, MAOIs). The results from this study would help inform treatment decisions for patients with treatment-resistant depression and potentially guide clinical guidelines.

**Idea 3: Risk factors associated with medication discontinuation among patients initiating antidiabetic medications**This study would investigate the predictors of medication discontinuation among individuals who initiate antidiabetic medications, such as metformin or sulfonylureas. Using OMOP CDM data, researchers could identify a cohort of patients starting an antidiabetic medication and analyze factors associated with treatment discontinuation (e.g., comorbidities, previous medications, healthcare utilization). The findings from this study could inform strategies for improving adherence to antidiabetic therapies and reducing the burden of diabetes management.")

=# 
