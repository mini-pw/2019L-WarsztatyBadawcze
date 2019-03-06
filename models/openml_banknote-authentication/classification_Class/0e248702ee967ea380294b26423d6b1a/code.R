#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
banknote_authentication <- getOMLDataSet(data.id = 1462L)
banknote <- banknote_authentication$data
head(banknote)

#:# preprocessing
head(banknote)

#:# model
classif_task = makeClassifTask(id = "banknote", data = banknote, target = "Class")
classif_lrn = makeLearner("classif.bartMachine", predict.type = "prob")

#:# hash 
#:# 0e248702ee967ea380294b26423d6b1a
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
