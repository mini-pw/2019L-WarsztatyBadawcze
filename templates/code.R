#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
liver_disorders <- getOMLDataSet(data.id = 8L)
liver <- liver_disorders$data
head(liver)

#:# preprocessing
head(liver)

#:# model
regr_task = makeRegrTask(id = "lvr", data = liver, target = "drinks")
regr_lrn = makeLearner("regr_gbm", par.vals = list(n.trees = 500, interaction.depth = 3))

#:# hash 
#:# 5b2c4babcf5363847614d2b486a71534
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv)
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo_", hash,".txt"))
sessionInfo()
sink()
