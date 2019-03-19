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
fertility$V1 <- factor(fertility$V1)
head(fertility)

#:# model
classif_task <- makeClassifTask(id = "task", data = fertility, target = "V1")
classif_lrn <- makeLearner("classif.boosting", predict.type = "prob")

#:# hash
#:# 768d210c342d9c0d201c1404fb8be601
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc))
r$aggr

#:#
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()