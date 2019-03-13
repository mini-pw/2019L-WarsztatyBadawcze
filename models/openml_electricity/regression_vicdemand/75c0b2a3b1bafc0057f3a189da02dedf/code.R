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
regr_task <- makeRegrTask(id = "task", data = electr, target = "vicdemand")
regr_lrn <- makeLearner("regr.earth")

#:# hash 
#:# 75c0b2a3b1bafc0057f3a189da02dedf
hash <- digest(list(regr_task, regr_lrn))
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
