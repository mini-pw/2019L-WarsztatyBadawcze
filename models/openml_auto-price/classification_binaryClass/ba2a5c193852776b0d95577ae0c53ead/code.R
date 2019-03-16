#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(adabag)

#:# config
set.seed(1)

#:# data
auto_price <- getOMLDataSet(data.id = 745)
auto_price <- auto_price$data
df <- auto_price


#:# model
classif_task = makeClassifTask(id = "b2", data = auto_price, target = "binaryClass")
classif_lrn = makeLearner("classif.boosting", predict.type = "prob")

#:# hash 
#:# ba2a5c193852776b0d95577ae0c53ead
hash <- digest(classif_lrn)

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tpr, tnr, f1))

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()

