#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:#
set.seed(1)

#:# data
fertility_dat <- getOMLDataSet(data.id=1473)
fertility <- fertility_dat$data
head(fertility)

#:# preprocessing
head(fertility)


#:# model
regr_task <- makeRegrTask(id = "frt", data = fertility, target = "V2")
regr_lrn <- makeLearner("regr.glmboost")

#:# hash
#:# da6b7c3600352ec182e2a2a9121113ac
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, rsq, mae))
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
