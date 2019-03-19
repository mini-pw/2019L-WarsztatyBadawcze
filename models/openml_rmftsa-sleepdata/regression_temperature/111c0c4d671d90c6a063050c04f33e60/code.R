#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
rmftsa_sleepdata <- getOMLDataSet(data.id = 679L)
sleep <- rmftsa_sleepdata$data
head(sleep)

#:# preprocessing
head(sleep)

#:# model
regr_task = makeRegrTask(id = "task", data = sleep, target = "temperature")
regr_lrn = makeLearner("regr.gbm")

#:# hash 
#:# 111c0c4d671d90c6a063050c04f33e60
hash <- digest(list(regr_task, regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
