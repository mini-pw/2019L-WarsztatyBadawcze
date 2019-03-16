#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
electricity <- getOMLDataSet(data.id = 151L)
electr <- electricity$data
head(electr)

#:# preprocessing
head(electr)

#:# model
regr_task = makeRegrTask(id = "elc", data = electr, target = "vicdemand")
regr_lrn = makeLearner("regr.earth")

#:# hash 
#:# a6c911540d024c85b94402cde5c19f53
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
