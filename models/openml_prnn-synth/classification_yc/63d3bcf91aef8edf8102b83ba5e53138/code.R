#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
prnn_synth <- getOMLDataSet(data.id = 464L)
synth <- prnn_synth$data
head(synth)

#:# preprocessing
head(synth)

#:# model
classif_task = makeClassifTask(id = "task", data = synth, target = "yc")
classif_lrn = makeLearner("classif.logreg",  predict.type = "prob")

#:# hash 
#:# 63d3bcf91aef8edf8102b83ba5e53138
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()