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
head(irish)

#:# preprocessing

#:# model
class_task <- makeClassifTask(id = "irish_class", data = irish, target = "Sex")
class_lrn <- makeLearner("classif.boosting")

#:# hash 
#:# 5b2c4babcf5363847614d2b486a71534
hash <- digest(class_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(class_lrn, class_task, cv, measures = list(acc))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()