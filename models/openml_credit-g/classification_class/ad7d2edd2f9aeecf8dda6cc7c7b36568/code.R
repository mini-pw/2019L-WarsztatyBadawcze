#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(7744)

#:# data
credit <- getOMLDataSet(data.id = 31L)
credit <- credit$data
head(credit)

#:# preprocessing

#:# model
classif_task = makeClassifTask(id = "lvr", data = credit, target = "class")
classif_lrn = makeLearner("classif.svm", predict.type = "prob")

#:# hash 
#:# ad7d2edd2f9aeecf8dda6cc7c7b36568
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()