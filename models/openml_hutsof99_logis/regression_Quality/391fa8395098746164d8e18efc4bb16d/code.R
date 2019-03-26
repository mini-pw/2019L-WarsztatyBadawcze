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
lrn = makeLearner("regr.plsr", par.vals = list(method = "oscorespls"))

#:# hash
#:# 391fa8395098746164d8e18efc4bb16d
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
