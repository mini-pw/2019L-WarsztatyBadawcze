#:# libraries
library(OpenML)
library(mlr)
library(farff)
library(digest)

#:# config
set.seed(1)

#:# data
irish <- getOMLDataSet(data.id = 451L)
irish <- irish$data
df <- irish
head(irish)

#:# preprocessing

#:# model
classif_task <- makeClassifTask(data = irish, target = "Sex", id="task")
classif_lrn <- makeLearner("classif.boosting", predict.type = "prob")

#:# hash 
#:# ba2a5c193852776b0d95577ae0c53ead
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1)) 


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
