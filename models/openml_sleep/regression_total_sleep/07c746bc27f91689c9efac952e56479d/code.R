#:# libraries
library(OpenML)
library(mlr)
library(digest)

#:# config
set.seed(1)

#:# data
sleep <- getOMLDataSet(data.id = 205L)
sleep <- sleep$data
head(sleep)

#:# preprocessing
sleep <- na.omit(sleep)


#:# model
regr_task <- makeRegrTask(id = "sleep_regr", data = sleep, target = "total_sleep")
regr_lrn <- makeLearner("regr.rpart", par.vals = list(maxdepth = 4))

#:# hash 
#:# 07c746bc27f91689c9efac952e56479d
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse))
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
