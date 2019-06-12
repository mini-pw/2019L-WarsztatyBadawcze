#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = "kc1-binary")
head(dataset$data)

#:# preprocessing
head(dataset$data)

#:# model
task = makeClassifTask(id = "task", data = dataset$data, target = "DL")
lrn = makeLearner("classif.rda", par.vals = list(), predict.type = "prob")

#:# hash
#:# 38284f4514d5a0d9ff05d24c340520a3
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
