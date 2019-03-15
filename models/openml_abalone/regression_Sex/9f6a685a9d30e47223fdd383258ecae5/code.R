#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
dane <- getOMLDataSet(data.id = 183L)
df <- dane$data
head(df)

#:# preprocessing
df <- df[df$Sex=="M" | df$Sex=="F",-9]
df$Sex <- as.integer(df$Sex)
head(df)

#:# model
regr_task = makeRegrTask(id = "task", data = df, target = "Sex")
regr_lrn = makeLearner("regr.lm")

#:# hash 
#:# 9f6a685a9d30e47223fdd383258ecae5
hash <- digest(list(regr_task, regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
r$aggr

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
