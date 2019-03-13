#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(4)

#:# data
boston_dataset <- getOMLDataSet(data.id = 853)
boston <- boston_dataset$data
head(boston)

#:# preprocessing
head(boston)

#:# model
regr_task = makeRegrTask(id = "boston", data = boston, target = "TAX")
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