#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
diabetes_set <- getOMLDataSet(data.id = 37L) 
diabetes <- diabetes_set$data
head(diabetes)

#:# preprocessing
head(diabetes)

#:# model
classif_task <- makeClassifTask(id = "diab", data = diabetes, target = "class")
classif_lrn <- makeLearner("classif.logreg", predict.type = "prob")

#:# hash
#:# 387c82721c99b109bcaad4eb46eb2618
hash <- digest(classif_task)
hash

#:# audit 
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(auc,acc))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
