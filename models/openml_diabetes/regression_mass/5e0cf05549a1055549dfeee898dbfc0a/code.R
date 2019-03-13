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
task = makeRegrTask(id = "mass.regr", data = dat, target = "mass")
lrn = makeLearner("regr.plsr")

#:# hash 
#:# 5e0cf05549a1055549dfeee898dbfc0a
hash <- digest(regr_lrn)
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