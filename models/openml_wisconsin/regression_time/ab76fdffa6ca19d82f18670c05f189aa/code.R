#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = "wisconsin")
head(dataset$data)

#:# preprocessing
head(dataset$data)

#:# model
task = makeRegrTask(id = "task", data = dataset$data, target = "time")
lrn = makeLearner("regr.frbs", par.vals = list(method = "WM", type.mf = "GAUSSIAN"))

#:# hash
#:# ab76fdffa6ca19d82f18670c05f189aa
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
