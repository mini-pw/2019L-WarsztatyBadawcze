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
regr_task <- makeRegrTask(id = "task", data = dat, target = "mass")
regr_lrn <- makeLearner("regr.plsr")

#:# hash 
#:# 66ca68532158b416b4260fd4b9cb0929
hash <- digest(list(regr_task, regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(lrn, task, cv, measures = list(mse, rmse, mae, rsq))
Agr <- r$aggr
Agr

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()