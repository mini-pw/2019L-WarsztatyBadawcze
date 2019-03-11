#:# libraries
library(OpenML)
library(mlr)
library(digest)

#:# config
set.seed(1)

#:# data
auto <- getOMLDataSet(data.id = 745L)
auto <- auto$data
df <- auto

#:# preprocessing

#:# model
regr_task <- makeRegrTask(id = "auto_regr", data = auto, target = "horsepower")
regr_lrn <- makeLearner("regr.rpart", par.vals = list(maxdepth = 10))

#:# hash 
#:# 18d5cd204525c38c5926e0c3192c5baa
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()