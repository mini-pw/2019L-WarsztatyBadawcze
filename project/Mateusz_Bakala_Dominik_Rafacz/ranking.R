# NAJPIERW TRZEBA USTAWIC DIR NA TEN FOLDER
library(jsonlite)
source("functions/model_metrics.R")
source("functions/elo.R")

# uruchomic za pierwszym razem:
source("transform.R")

reference <- read_json("dataset.json")[[1]]

# tylko dla mnie ~Mati
setwd("~/git/CaseStudies2019S/models")
#a to dla mne ~Dom's
setwd("~/CS/CaseStudies2019S/models")

count_factors_range(reference)
count_nums_skewness(reference)

computeAllSimiliarities()

# przykładowe wywołanie
result <- computeELOScores()
