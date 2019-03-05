#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(randomForestSRC)

#:# config
set.seed(997)

#:# data
skin_seg <- getOMLDataSet(data.id = 1502)
skin_seg <- skin_seg$data

#:# preprocessing
head(skin_seg)

#:# model
classif_task = makeClassifTask(data = skin_seg, target = "Class")
classif_lrn = makeLearner("classif.logreg", predict.type = "prob")

#:# hash 
#:# 4854f305f42ae8beb4f19d3de2ba2d8e
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
