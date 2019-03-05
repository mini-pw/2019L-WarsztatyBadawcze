

#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
df <- read.csv("lupus.csv")

#:# model
classif_task = makeClassifTask(id = "lupus", data = df, target = "STATUS")
classif_lrn =  makeLearner("classif.rpart", predict.type = "prob", fix.factors.prediction = TRUE)
#:# hash 

#:# 5b2c4babcf5363847614d2b486a71534
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv)
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()

source("generator.R")
make3JSON()
