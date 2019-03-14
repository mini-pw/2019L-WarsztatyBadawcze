#:# libraries
library(digest)
library(OpenML)
library(mlr)



#:# config
set.seed(1)

#:# data
Sea_full <- getOMLDataSet(data.id = 161L)
Sea <- Sea_full$data
head(Sea)

#:# preprocessing
head(Sea)

#:# model
regr_task = makeRegrTask(id = "task", data = Sea, target = "attrib1")
regr_lrn = makeLearner("regr.lm")

#:# hash 
#:# 9d85b0b5d75456fed4fd4a9ed5cdeed1
hash <- digest(list(regr_task, regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv,measures = list(mse,rmse,mae,rsq))
r$aggr


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()