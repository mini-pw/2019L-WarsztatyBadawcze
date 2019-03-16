#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(farff)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
geyser_ds <- getOMLDataSet(data.id = 712L)
geyser <- geyser_ds$data
head(geyser)

#:# preprocessing
head(geyser)

#:# model
regr_task = makeRegrTask(id = "g", data = geyser, target = "col_3")
regr_lrn = makeLearner("regr.rvm")

#:# hash 
#:# 3e73eb3740a19a2c12efacc5c0af48c5
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
