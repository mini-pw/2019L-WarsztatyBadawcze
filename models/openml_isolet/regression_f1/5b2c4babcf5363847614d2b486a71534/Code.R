#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
df <- read.csv("phpB0xrNj.csv")
#:# preprocessing


#:# model
regr_task = makeRegrTask(id = "isolet", data = df, target = "f1")
regr_lrn = makeLearner("regr.gbm", par.vals = list(n.trees = 500, interaction.depth = 3))

#:# hash 
#:# 5b2c4babcf5363847614d2b486a71534
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv)
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
source("generator.R")
make3JSON()
