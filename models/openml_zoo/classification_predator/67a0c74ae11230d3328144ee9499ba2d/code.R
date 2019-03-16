#:# libraries
library(OpenML)
library(mlr)
library(farff)
library(digest)

#:# config
set.seed(1)

#:# data
zoo <- getOMLDataSet(data.id = 62L)
zoo <- zoo$data
df <- zoo

#:# preprocessing

#:# model
classif_task <- makeClassifTask(id = "zoo", data = zoo, target = "predator")
classif_lrn <- makeLearner("classif.rpart", predict.type = "prob")

#:# hash 
#:# 67a0c74ae11230d3328144ee9499ba2d
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1)) 


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
