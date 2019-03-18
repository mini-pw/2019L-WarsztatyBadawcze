#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(gbm)
library(kknn)

#:# config
set.seed(1)

#:# data
art_char_set <- getOMLDataSet(data.id = 1459L) 
art_char <- art_char_set$data
head(art_char)

#:# preprocessing
head(art_char)

#:# model
classif_task <- makeClassifTask(id = "task", data = art_char, target = "Class")
classif_lrn <- makeLearner("classif.kknn", predict.type = "prob")


#:# hash
#:# 7d1e71e7e7a35c5650176983941e5fa8
hash <- digest(list(classif_task,classif_lrn))
hash

#:# audit 
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc,multiclass.au1p,multiclass.au1u,multiclass.aunp,multiclass.aunu))
ACC <- r$aggr[1]
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()