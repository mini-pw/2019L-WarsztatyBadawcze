#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
banknote_authentication <- getOMLDataSet(data.id = 1462L)
banknote <- banknote_authentication$data
head(banknote)

#:# preprocessing
head(banknote)

#:# model
classif_task = makeClassifTask(id = "task", data = banknote, target = "Class")
classif_lrn = makeLearner("classif.bartMachine", predict.type = "prob", seed=123)

#:# hash 
#:# 329e26fc4ac7088ca02526dd5ab088ea
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
