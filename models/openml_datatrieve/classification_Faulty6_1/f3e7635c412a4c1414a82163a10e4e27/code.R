#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = "datatrieve")
head(dataset$data)

#:# preprocessing
head(dataset$data)

#:# model
task = makeClassifTask(id = "task", data = dataset$data, target = "Faulty6_1")
lrn = makeLearner("classif.ctree", par.vals = list(), predict.type = "prob")

#:# hash
#:# f3e7635c412a4c1414a82163a10e4e27
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
