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
classif_task = makeClassifTask(id = "yc", data = synth, target = "yc")
classif_lrn = makeLearner("classif.svm",  predict.type = "prob")

#:# hash 
#:# c4867ef613cda9c0fb603c5c2f056d8a
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
