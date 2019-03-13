#:# libraries
library(digest)
library(OpenML)
library(mlr)

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
classif_task = makeClassifTask(id = "bc", data = dat, target = "Class")
classif_lrn = makeLearner("classif.kknn", predict.type = "prob")

#:# hash 
#:# 17d36960d513eaeb991058a7aa8bf57b
hash <- digest(classif_lrn)
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
