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
r <- resample(classif_lrn, classif_task, cv, measures = list(acc,auc,tnr,tpr,tp,fp,f1))
ACC <- r$aggr[1]
ACC
AUC <- r$aggr[2]
AUC
Specificity <- r$aggr[3]
Specificity
Recall <- r$aggr[4]
Recall
Precision <- (r$aggr[5]/(r$aggr[5] + r$aggr[6]))
Precision
F1 <- r$aggr[7]
F1

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
