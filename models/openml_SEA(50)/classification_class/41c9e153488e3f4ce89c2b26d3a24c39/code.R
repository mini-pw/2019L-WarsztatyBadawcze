#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(h2o)

#:# config
set.seed(1)

#:# data
Sea_full <- getOMLDataSet(data.id = 161L)
Sea <- Sea_full$data
head(Sea)

#:# preprocessing
head(Sea)

#:# model
classif_task = makeClassifTask(id = "task", data = Sea, target = "class")
classif_lrn = makeLearner("classif.h2o.deeplearning", predict.type = "prob")

#:# hash 
#:# 41c9e153488e3f4ce89c2b26d3a24c39
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
r$aggr


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
