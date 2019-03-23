#:# libraries
library(OpenML)
library(mlr)
library(farff)
library(digest)

#:# config
set.seed(1)

#:# data
sleep <- getOMLDataSet(data.id = 205L)
sleep <- sleep$data
head(sleep)

#:# preprocessing
sleep <- na.omit(sleep)
sleep$danger_index <-as.factor(sleep$danger_index)

#:# model
classif_task <- makeClassifTask(id = "sleep", data = sleep, target = "danger_index")
classif_lrn <- makeLearner("classif.randomForestSRC", predict.type = "prob")

#:# hash 
#:# ff9b66ce3c6b7c935306374bdecacf80
hash <- digest(list(classif_task,classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc))


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
