#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = "mbagrade")
head(dataset$data)

#:# preprocessing
head(dataset$data)

#:# model
task = makeRegrTask(id = "task", data = dataset$data, target = "grade_point_average")
lrn = makeLearner("regr.svm", par.vals = list(kernel = "radial"))

#:# hash
#:# 650f46e36318b303662dfc0a52356bd9
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
