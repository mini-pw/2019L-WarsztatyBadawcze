#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = "backache")
head(dataset$data)

#:# preprocessing
head(dataset$data)

#:# model
task = makeClassifTask(id = "task", data = dataset$data, target = "col_33")
lrn = makeLearner("classif.earth", par.vals = list(), predict.type = "prob")

#:# hash
#:# 21000ee05217fb4ceed8eedc0fd2ecb7
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
