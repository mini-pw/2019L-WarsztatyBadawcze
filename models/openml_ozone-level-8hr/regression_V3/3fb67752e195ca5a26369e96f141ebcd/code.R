#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(farff)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
ozone_ds <- getOMLDataSet(data.id = 1487L)
ozone <- ozone_ds$data
head(ozone)

#:# preprocessing
head(ozone)

#:# model
regr_task = makeRegrTask(id = "oz", data = ozone, target = "V3")
regr_lrn = makeLearner("regr.nnet", par.vals = list(size = 5, maxit = 1000))

#:# hash 
#:# 3fb67752e195ca5a26369e96f141ebcd
hash <- digest(regr_lrn)
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
