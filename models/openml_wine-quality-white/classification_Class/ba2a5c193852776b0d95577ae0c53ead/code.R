#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
white_wine <- getOMLDataSet(data.id = 40498L)
wine <- white_wine$data
head(wine)

#:# preprocessing
head(wine)

#:# model
classifTask <- makeClassifTask(id="classif", data = wine, target = "Class")
learner <- makeLearner("classif.boosting", predict.type = "prob")

#:# hash 
#:# ba2a5c193852776b0d95577ae0c53ead
hash <- digest(learner)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(learner,classifTask,cv,measures=list(acc))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
