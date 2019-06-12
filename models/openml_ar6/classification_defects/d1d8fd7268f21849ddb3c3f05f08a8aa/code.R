#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = "ar6")
head(dataset$data)

#:# preprocessing
head(dataset$data)

#:# model
task = makeClassifTask(id = "task", data = dataset$data, target = "defects")
lrn = makeLearner("classif.logreg", par.vals = list(), predict.type = "prob")

#:# hash
#:# d1d8fd7268f21849ddb3c3f05f08a8aa
hash <- digest(list(task, lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- mlr::resample(lrn, task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
