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
classif_task <- makeClassifTask(id = "task", data = zoo, target = "venomous")
classif_lrn <- makeLearner("classif.ada", predict.type = "prob")

#:# hash 
#:# 147da89c2ea06175928b517c966f7594
hash <- digest(list(classif_task, classif_task))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 4)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1)) 


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
