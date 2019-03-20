#:# libraries
library(digest)
library(mlr)
library(readr)
library(dplyr)

#:# config
set.seed(1)

#:# data
enc <- guess_encoding("toy_dataset.csv", n_max = 10000)[[1]]
df <- as.data.frame(read_csv("toy_dataset.csv", locale = locale(encoding = enc[1])))
head(df)

#:# preprocessing
df <- select(df, -Number)
df$City <- as.factor(df$City)
df$Illness <- as.factor(df$Illness)
head(df)

#:# model
classif_task <- makeClassifTask(id = "task", data = df, target = "Gender")
classif_lrn <- makeLearner("classif.gbm", predict.type = "prob",
                           par.vals = list(distribution = "bernoulli"))

#:# hash 
#:# cceb7a7795cc60c06fcf686110b07ee4
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
measure <- r$aggr
measure

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()