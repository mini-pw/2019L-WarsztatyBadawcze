#:# libraries
library(OpenML)
library(mlr)
library(digest)

#:# config
set.seed(1)

#:# data
irish <- getOMLDataSet(data.id = 451L)
irish <- irish$data
df <- irish
head(irish)

#:# preprocessing

#:# model
regr_task <- makeRegrTask(id = "task", data = irish, target = "DVRT")
regr_lrn <- makeLearner("regr.rpart", par.vals = list(maxdepth = 5))

#:# hash 
#:# f1657350d7c63bcd86b6d73696968281
hash <- digest(list(regr_task, regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
