#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
auto_price <- getOMLDataSet(data.id = 745)
auto_price <- auto_price$data
df <- auto_price

#:# model
regr_task = makeRegrTask(id = "task", data = auto_price, target = "horsepower")
regr_lrn = makeLearner("regr.glm")

#:# hash 
#:# "70c912dc6d606a85501e09c8afbefec6"
hash <- digest(list(regr_task,regr_lrn))
hash
#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse,rmse,mae,rsq))

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()

