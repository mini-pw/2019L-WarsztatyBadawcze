#:# libraries
library(digest)
library(OpenML)
library(mlr)
library("gbm")


#:# config
set.seed(1)

#:# data
Sea_full <- getOMLDataSet(data.id = 161L)
Sea <- Sea_full$data
head(Sea)

#:# preprocessing
head(Sea)

#:# model
regr_task = makeRegrTask(id = "Sea", data = Sea, target = "attrib1")
regr_lrn = makeLearner("regr.gbm", par.vals = list(n.trees = 500, interaction.depth = 3))

#:# hash 
#:# 61e76ce015f3433786f04c2700266f89
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse,rmse,mae,rsq))
r$aggr


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
