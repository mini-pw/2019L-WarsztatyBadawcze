#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(farff)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
geyser_ds <- getOMLDataSet(data.id = 712L)
geyser <- geyser_ds$data
head(geyser)

#:# preprocessing
head(geyser)

#:# model
regr_task = makeRegrTask(id = "task", data = geyser, target = "col_3")
regr_lrn = makeLearner("regr.rvm")

#:# hash 
#:# 800e6b2ac2b9e0cb6309e97222354cc4
hash <- digest(list(regr_task,regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
agr <- r$aggr
agr

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
