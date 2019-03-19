#:# libraries
library(OpenML)
library(mlr)
library(farff)
library(digest)
library(e1071)


#:# config
set.seed(1)

#:# data
Sea_full <- getOMLDataSet(data.id = 161L)
Sea <- Sea_full$data
head(Sea)

#:# preprocessing

#:# model
classif_task <- makeClassifTask(id = "task", data = Sea, target = "class")
classif_lrn <- makeLearner("classif.naiveBayes", predict.type = "prob")

#:# hash 
#:# 137d4aa57c3fed54e30b6eb4f4a4bc74

hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1)) 


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()