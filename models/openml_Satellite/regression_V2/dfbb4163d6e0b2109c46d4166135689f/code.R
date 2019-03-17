#:# libraries
library(OpenML)
library(mlr)
library(digest)

#:# config
set.seed(1)

#:# data
satelite <- getOMLDataSet(data.id = 40900L)
satelite <- satelite$data
df <- satelite

#:# preprocessing

#:# model
regr_task <- makeRegrTask(id = "task", data = satelite, target = "V2")
regr_lrn <- makeLearner("regr.rpart", par.vals = list(maxdepth = 10))

#:# hash 
#:# dfbb4163d6e0b2109c46d4166135689f
hash <- digest(list(regr_task, regr_task))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
