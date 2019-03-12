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
task = makeClassifTask(id = "abalone", data = dataset, target = "sex")
lrn = makeLearner("classif.nnTrain", par.vals = list(), predict.type = "prob")

#:# hash 
#:# 1a235eaf14ddf2d90f2b5c9519772786
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
