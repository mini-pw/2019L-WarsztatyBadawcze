#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(997)

#:# data
auto.price <- getOMLDataSet(data.id = 745L)
auto.price <- auto.price$data
auto.price$binaryClass <- as.numeric(auto.price$binaryClass)
auto.price$symboling <- as.numeric(auto.price$symboling)

#:# preprocessing
head(auto.price)

#:# model
regr_task = makeRegrTask(data = auto.price, target = "length")
regr_lrn = makeLearner("regr.xgboost")

#:# hash 
#:# 435aa911c12ebd1146d9df0a6b4c5dc8
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, mae, rmse, rsq))
er <- r$aggr
er

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
