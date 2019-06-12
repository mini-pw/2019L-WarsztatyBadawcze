#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = "Australian")
head(dataset$data)

#:# preprocessing
head(dataset$data)

#:# model
task = makeClassifTask(id = "task", data = dataset$data, target = "A15")
lrn = makeLearner("classif.earth", par.vals = list(), predict.type = "prob")

#:# hash
#:# c90a2ac3e62689c67876f24f665d3c0d
hash <- digest(list(task, lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- mlr::resample(lrn, task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
