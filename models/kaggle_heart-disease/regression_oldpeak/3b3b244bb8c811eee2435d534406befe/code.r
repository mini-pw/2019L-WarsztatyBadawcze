#:# libraries
library(digest)
library(mlr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv("heart.csv")
head(dataset)

#:# preprocessing
head(dataset)

#:# model
task = makeRegrTask(id = "kaggle_heart_disease_regression", data = dataset, target = "oldpeak")
lrn = makeLearner("regr.rpart", par.vals = list(maxdepth = 5))

#:# hash 
#:# 3b3b244bb8c811eee2435d534406befe
hash <- digest(lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(lrn, task, cv, measures = list(mse))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
