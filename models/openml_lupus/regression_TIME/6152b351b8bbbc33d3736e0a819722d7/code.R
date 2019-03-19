#:# libraries

library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
data <- getOMLDataSet(data.id = 472L)
head(df)
df <- data$data

#:# preprocessing
head(df)

#:# model
task <- makeRegrTask(id = "task", data = df, target = "TIME")
task <- createDummyFeatures(obj = task)
#learner <- makeLearner("regr.lm")
learner <- makeLearner("regr.evtree")

#:# hash
#:# 6152b351b8bbbc33d3736e0a819722d7
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