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
classif_task <- makeClassifTask(id = "task", data = dat, target = "class")
classif_lrn <- makeLearner("classif.randomForest", predict.type = "prob")

#:# hash
#:# 75e556e26ffc96fc9b0982c26c081331
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
