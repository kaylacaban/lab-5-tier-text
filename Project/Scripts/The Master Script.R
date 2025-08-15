# Project/Scripts/The Master Script

# Load packages and setup environment
source("environment.R")

# Download screenplay (if it hasn't already been downloaded)
if (!file.exists("Project/Data/InputData/revenge_sith_raw.txt")) {
  source("Project/Scripts/ProcessingScripts/01_scrape_imsdb.R")
}

# Run tokenization and analysis script
source("Project/Scripts/AnalysisScripts/02_tokenise_analysis.R")

