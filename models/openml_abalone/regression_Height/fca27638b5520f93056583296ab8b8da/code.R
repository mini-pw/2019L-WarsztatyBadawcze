#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
abalone_dataset <- getOMLDataSet(data.id = 183)
abalone <- abalone_dataset$data
head(abalone)

#:# preprocessing
head(abalone)

#:# model
regr_task = makeRegrTask(id = "abalone", data = abalone, target = "Height")
regr_lrn = makeLearner("regr.bcart")
#:# hash 
hash <- digest(c(regr_task,regr_lrn))
hash

#:# audit
#:# fca27638b5520f93056583296ab8b8da
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
mse <- r$aggr
mse

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()