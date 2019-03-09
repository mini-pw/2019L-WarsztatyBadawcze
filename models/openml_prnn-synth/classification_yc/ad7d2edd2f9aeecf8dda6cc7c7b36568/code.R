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
#:# ad7d2edd2f9aeecf8dda6cc7c7b36568
hash <- digest(class_lrn)
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
