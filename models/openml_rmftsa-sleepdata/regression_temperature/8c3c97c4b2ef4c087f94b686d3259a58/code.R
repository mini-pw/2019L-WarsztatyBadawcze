#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
rmftsa_sleepdata <- getOMLDataSet(data.id = 679L)
sleep <- sleep_data$data
head(sleep)

#:# preprocessing
head(sleep)

#:# model
regr_task = makeRegrTask(id = "temp", data = sleep, target = "temperature")
regr_lrn = makeLearner("regr.gbm")

#:# hash 
#:# 8c3c97c4b2ef4c087f94b686d3259a58
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv)
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
