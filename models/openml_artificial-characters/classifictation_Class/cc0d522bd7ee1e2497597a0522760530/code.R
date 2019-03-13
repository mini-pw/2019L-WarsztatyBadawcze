#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(gbm)
library(e1071)

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
classif_lrn <- makeLearner("classif.naiveBayes", predict.type = "prob")


#:# hash
#:# cc0d522bd7ee1e2497597a0522760530
hash <- digest(list(classif_task,classif_lrn))
hash

#:# audit 
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_naive, cv, measures = list(acc,multiclass.au1p,multiclass.au1u,multiclass.aunp,multiclass.aunu))
ACC <- r$aggr[1]
ACC
AUC1vs1 <- r$aggr[3]
AUC1vs1
AUCweighted1vs1 <- r$aggr[2]
AUCweighted1vs1
AUC1vsRest <- r$aggr[5]
AUC1vsRest
AUCweighted1vsRest <- r$aggr[4]
AUCweighted1vsRest

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
