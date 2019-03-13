#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
diabetes <- getOMLDataSet(data.id = 37L)
dat <- diabetes$data
head(dat)

#:# preprocessing
head(dat)
dat <- na.omit(dat)

#:# model
classif_task <- makeClassifTask(id = "class.class", data = dat, target = "class")
classif_lrn <- makeLearner("classif.randomForest", predict.type = "prob")

#:# hash
#:# e2c4980ad46218287bef2e4c0829c02d
hash <- digest(classif_task)
hash

#:# audit 
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
Agr <- r$aggr
Agr

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
