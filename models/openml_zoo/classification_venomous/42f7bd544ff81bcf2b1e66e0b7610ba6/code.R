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
classif_task <- makeClassifTask(id = "zoo", data = zoo, target = "venomous")
classif_lrn <- makeLearner("classif.ada", predict.type = "prob")

#:# hash 
#:# 42f7bd544ff81bcf2b1e66e0b7610ba6
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 4)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1)) 


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()