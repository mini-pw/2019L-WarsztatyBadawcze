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
lrn = makeLearner("classif.randomForest", par.vals = list(ntree = 200, mtry = 4), predict.type = "prob")

#:# hash
#:# dc0b02400709e4bcc71492435eed6c10
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
