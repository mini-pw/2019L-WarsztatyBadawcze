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
lrn = makeLearner("classif.binomial", par.vals = list(link = "probit"), predict.type = "prob")

#:# hash
#:# a12cd1320d72e7b4ec0b9094bc9a7304
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
