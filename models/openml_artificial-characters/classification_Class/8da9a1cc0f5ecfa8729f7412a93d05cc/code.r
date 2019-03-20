#:# libraries
library(digest)
library(mlr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv("phpPQrHPH.csv")
head(dataset)

#:# preprocessing
head(dataset)

#:# model
task = makeClassifTask(id = "phppqrhph", data = dataset, target = "Class")
lrn = makeLearner("classif.randomForest", par.vals = list(), predict.type = "prob")

#:# hash 
#:# 8da9a1cc0f5ecfa8729f7412a93d05cc
hash <- digest(lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(lrn, task, cv, measures = list(acc))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
