#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
df <- read.csv("phpB0xrNj.csv")
#:# preprocessing


#:# model
regr_task = makeRegrTask(id = "isolet", data = df, target = "f1")
regr_lrn = makeLearner("regr.gbm", par.vals = list(n.trees = 500, interaction.depth = 3))

#:# hash 
#:# f55a2ad46af3966d8377aa2e2b44fb09
hash <- digest(list(regr_task, regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
source("generator.R")
make3JSON(df, "maksymiuks", "openml_isolet", "regression", regr_task, regr_lrn, c("mse", "rmse", "mae", "r2"))
