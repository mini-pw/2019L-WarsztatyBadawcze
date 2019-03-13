#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(gbm)

#:# config
set.seed(1)

#:# data
diabetes_set <- getOMLDataSet(data.id = 37L) 
diabetes <- diabetes_set$data
head(diabetes)

#:# preprocessing
head(diabetes)

#:# model
regr_task <- makeRegrTask(id = "diab", data = diabetes, target = "pedi")
regr_lrn <- makeLearner("regr.gbm", par.vals = list(n.trees = 500, interaction.depth = 3))

#:# hash
#:# 7388a6e027f8648dbc177df228c6eed6
hash <- digest(regr_task)
hash

#:# audit 
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse,rmse,mae,rsq))
MSE <- r$aggr[1]
MSE
RMSE <- r$aggr[2]
RMSE
MAE <- r$aggr[3]
MAE
R2 <- r$aggr[4]
R2

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
