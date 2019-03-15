#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = churn)
head(dataset)

#:# preprocessing
head(dataset)

#:# model
task = makeClassifTask(id = "task", data = dataset, target = "class")
lrn = makeLearner("classif.kknn", par.vals = list(), predict.type = "prob")

#:# hash
#:# 78f10f5935583e71f81bb60cf2273b03
hash <- digest(list(task, lrn))
hash

#:# auditcv <- makeResampleDesc("CV", iters = 5)
r <- mlr::resample(lrn, task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
