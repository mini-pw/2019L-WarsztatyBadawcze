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
classif_task = makeClassifTask(id = "task", data = liver, target = "selector")
classif_lrn = makeLearner("classif.glmnet", predict.type = "prob")

#:# hash 
#:# e9ad52ac38aa4dedf92095b699914932
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
