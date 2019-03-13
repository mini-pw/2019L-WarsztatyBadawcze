#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
electricity <- getOMLDataSet(data.id = 151L)
electr <- electricity$data
head(electr)

#:# preprocessing
head(electr)

#:# model
classif_task = makeClassifTask(id = "elc", data = electr, target = "class")
classif_lrn = makeLearner("classif.lda", predict.type = "prob")

#:# hash 
#:# 3159774690bf39c0fa98da7466e382c3
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()