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
task = makeClassifTask(id = "image-seg", data = dataset, target = "pixel.class")
lrn = makeLearner("classif.randomForest", par.vals = list(), predict.type = "prob")

#:# hash 
#:# 95842077c0cec4f693b49e4ac3902054
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
