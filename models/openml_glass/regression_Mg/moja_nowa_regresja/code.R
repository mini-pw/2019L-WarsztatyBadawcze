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
#:# a83d5cf9f3c9dc688b8e1f64b2e92047
list_to_hash <-list(task, learner)
hash <- digest(list_to_hash)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
ACC <- r$aggr
ACC

#:# session_info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()