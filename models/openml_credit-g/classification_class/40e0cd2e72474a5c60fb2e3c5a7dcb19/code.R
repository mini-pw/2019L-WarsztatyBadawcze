#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = credit-g)
head(dataset)

#:# preprocessing
head(dataset)

#:# model
task = makeClassifTask(id = "task", data = dataset, target = "class")
lrn = makeLearner("classif.cforest", par.vals = list(ntree = 100, mtry = 6), predict.type = "prob")

#:# hash
#:# 40e0cd2e72474a5c60fb2e3c5a7dcb19
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
