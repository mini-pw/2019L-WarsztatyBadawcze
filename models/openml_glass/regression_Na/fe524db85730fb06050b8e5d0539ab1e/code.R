#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
glass_dataset <- getOMLDataSet(data.id = 41)
glass <- glass_dataset$data
head(glass)

#:# preprocessing
head(glass)

#:# model
regr_task = makeRegrTask(id = "glass", data = glass, target = "Na")
regr_lrn = makeLearner("regr.bcart")
#:# hash 
#:# fe524db85730fb06050b8e5d0539ab1e
hash <- digest(c(regr_task,regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
mse <- r$aggr
mse

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()