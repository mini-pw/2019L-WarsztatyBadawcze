#:# libraries
library(OpenML)
library(mlr)
library(digest)

#:# config
set.seed(1)

#:# data
irish <- getOMLDataSet(data.id = 451L)
irish <- irish$data
head(irish)

#:# preprocessing

#:# model
regr_task <- makeRegrTask(id = "irsh_regr", data = irish, target = "DVRT")
regr_lrn <- makeLearner("regr.rpart", par.vals = list(maxdepth = 5))

#:# hash 
#:# 3b3b244bb8c811eee2435d534406befe
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse))
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()