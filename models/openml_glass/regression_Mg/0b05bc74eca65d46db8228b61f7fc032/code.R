#:# libraries

library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
data <- getOMLDataSet(data.id = 41L)
head(df)
df <- data$data

#:# preprocessing
head(df)

#:# model
task <- makeRegrTask(id = "task", data = df, target = "Mg")
task <- createDummyFeatures(obj = task)
#regr_lrn = makeLearner("regr.lm")
learner <- makeLearner("regr.evtree")

#:# hash
#:# 0b05bc74eca65d46db8228b61f7fc032
list_to_hash <-list(task, learner)
hash <- digest(list_to_hash)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(learner, task, cv, measures = list(mse, rmse, mae, rsq))
ACC <- r$aggr
ACC

#:# session_info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()