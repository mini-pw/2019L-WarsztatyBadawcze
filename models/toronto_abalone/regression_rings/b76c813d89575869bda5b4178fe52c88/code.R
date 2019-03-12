#:# libraries
library(digest)
library(mlr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv("https://raw.githubusercontent.com/mini-pw/2019L-WarsztatyBadawcze_zbiory/master/toronto_abalone/abalone.csv")
head(dataset)

#:# preprocessing
head(dataset)

#:# model
task = makeRegrTask(id = "abalone", data = dataset, target = "rings")
lrn = makeLearner("regr.nnet", par.vals = list())

#:# hash 
#:# b76c813d89575869bda5b4178fe52c88
hash <- digest(lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(lrn, task, cv, measures = list(mse, rmse, mae, rsq))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
