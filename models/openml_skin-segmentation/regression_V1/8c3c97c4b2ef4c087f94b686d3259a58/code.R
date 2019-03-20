#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(gbm)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
skin_seg <- getOMLDataSet(data.id = 1502)
skin_seg <- skin_seg$data

#:# preprocessing
head(skin_seg)

#:# model
regr_task = makeRegrTask(data = skin_seg, target = "V1")
regr_lrn = makeLearner("regr.gbm")

#:# hash 
#:# 8c3c97c4b2ef4c087f94b686d3259a58
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
