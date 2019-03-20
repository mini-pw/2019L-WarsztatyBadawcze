#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(dplyr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
fertility_dat <- getOMLDataSet(data.id = 1473)
fertility <- fertility_dat$data
head(fertility)

#:# preprocessing
fertility$V3 <- factor(fertility$V3)
head(fertility)

#:# model
classif_task <- makeClassifTask(id = "task", data = fertility, target = "V3")
classif_lrn <- makeLearner("classif.binomial", predict.type = "prob")

#:# hash
#:# 94bdc21c4a2263884a00dad198630db5
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
r$aggr

#:#
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()