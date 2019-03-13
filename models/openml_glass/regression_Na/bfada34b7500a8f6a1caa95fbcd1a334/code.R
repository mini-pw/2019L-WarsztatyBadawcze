#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(2)

#:# data
glass_dataset <- getOMLDataSet(data.id = 41)
glass <- glass_dataset$data
head(glass)

#:# preprocessing
head(glass)

#:# model
regr_task = makeRegrTask(id = "glass", data = abalone, target = "Na")
regr_lrn = makeLearner("regr.bcart")
#:# hash 
#:# 5b2c4babcf5363847614d2b486a71534
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
mse <- r$aggr
mse

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()