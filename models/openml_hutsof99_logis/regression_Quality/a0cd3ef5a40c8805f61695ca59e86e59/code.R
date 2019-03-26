#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = "hutsof99_logis")
head(dataset$data)

#:# preprocessing
head(dataset$data)

#:# model
task = makeRegrTask(id = "task", data = dataset$data, target = "Quality")
lrn = makeLearner("regr.gausspr", par.vals = list(kernel = "polydot"))

#:# hash
#:# a0cd3ef5a40c8805f61695ca59e86e59
hash <- digest(list(task, lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- mlr::resample(lrn, task, cv, measures = list(mse, rmse, mae, rsq))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
