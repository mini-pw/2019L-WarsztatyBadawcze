#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(farff)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
breast_cancer <- getOMLDataSet(data.id = 13L)
dat <- breast_cancer$data
head(dat)

#:# preprocessing
head(dat)
dat <- na.omit(dat)

#:# model
classif_task = makeClassifTask(id = "task", data = dat, target = "Class")
classif_lrn = makeLearner("classif.kknn", predict.type = "prob")

#:# hash 
#:# b629fee12bc484aede97f759d1767272
hash <- digest(list(classif_task, classif_lrn))
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
