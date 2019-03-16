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
task = makeRegrTask(id = "task", data = dataset, target = "vedge.mean")
lrn = makeLearner("regr.rpart", par.vals = list())

#:# hash 
#:# 79cdcbed3ab962905f6918ed74554846
hash <- digest(task, lrn)
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
