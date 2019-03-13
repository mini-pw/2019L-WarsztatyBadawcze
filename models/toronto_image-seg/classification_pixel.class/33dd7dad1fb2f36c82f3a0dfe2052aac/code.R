#:# libraries
library(digest)
library(mlr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv("https://raw.githubusercontent.com/mini-pw/2019L-WarsztatyBadawcze_zbiory/master/toronto_image-seg/image-seg.csv")
head(dataset)

#:# preprocessing
head(dataset)

#:# model
task = makeClassifTask(id = "task", data = dataset, target = "pixel.class")
lrn = makeLearner("classif.randomForest", par.vals = list(), predict.type = "prob")

#:# hash 
#:# 33dd7dad1fb2f36c82f3a0dfe2052aac
hash <- digest(task, lrn)
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
