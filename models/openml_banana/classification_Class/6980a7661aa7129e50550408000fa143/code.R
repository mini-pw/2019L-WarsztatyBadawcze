#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
banana_dataset <- getOMLDataSet(data.id = 1460)
banana <- banana_dataset$data
head(banana)

#:# preprocessing
head(banana)

#:# model
classif_task = makeClassifTask(id = "banana2", data = banana, target = "Class")
classif_lrn = makeLearner("classif.svm", predict.type='prob')

#:# hash 
#:# 6980a7661aa7129e50550408000fa143
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
auc <- r$aggr
auc

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()