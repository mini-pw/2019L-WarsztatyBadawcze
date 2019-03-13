setwd("C:/Users/Piotr/Documents/Bogdan/Warsztaty badawcze/pd3/regression_V7/3b3b244bb8c811eee2435d534406befe")
#:# libraries
library(digest)
library(mlr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv("phpPQrHPH.csv")[,-8]
head(dataset)

#:# preprocessing
head(dataset)

#:# model
task = makeRegrTask(id = "phpregression", data = dataset, target = "V7")
lrn = makeLearner("regr.rpart", par.vals = list(maxdepth = 5))

#:# hash 
#:# 3b3b244bb8c811eee2435d534406befe
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
