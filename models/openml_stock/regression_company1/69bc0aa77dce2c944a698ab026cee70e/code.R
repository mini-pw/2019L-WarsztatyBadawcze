#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(gbm)

#:# config
set.seed(1233,"L'Ecuyer")


#:# data
dataSet <- getOMLDataSet(data.id = 841L)
data <- dataSet$data

#:# preprocessing
head(data)
summary(data)

#:# model
regr_task <- makeRegrTask(id="stock_reg", data = data, target = "company1")
regr_lrn <- makeLearner("regr.gbm",par.vals = list(n.trees=2000))


#:# hash 
hash <- digest(regr_lrn)
hash


#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn,regr_task,cv,measures = list(mse,rmse,mae,rsq))
perf <- r$aggr
names(perf) <- c("MSE","RMSE","MAE","R2")
perf

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
