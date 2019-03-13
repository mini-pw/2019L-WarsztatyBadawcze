#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
zoo <- getOMLDataSet(data.id = 62L)
zoo <- zoo$data
head(zoo)

#:# preprocessing


#:# model
classif_task = makeClassifTask(id = "zoo", data = zoo, target = "predator")
classif_lrn = makeLearner("classif.boosting", predict.type = "prob")

#:# hash 
#:# ba2a5c193852776b0d95577ae0c53ead
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



getParamSet(classif_lrn)
helpLearnerParam(classif_lrn)
getHyperPars(classif_lrn)
?rpart::rpart.control
?adabag::boosting
