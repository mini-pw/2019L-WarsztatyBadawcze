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
classif_task = makeClassifTask(id = "lvr", data = liver, target = "selector")
classif_lrn = makeLearner("classif.glmnet", predict.type = "prob")

#:# hash 
#:# 61e76ce015f3433786f04c2700266f89
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
