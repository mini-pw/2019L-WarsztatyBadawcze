#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
skin_seg <- getOMLDataSet(data.id = 1502)
skin_seg <- skin_seg$data

#:# preprocessing
head(skin_seg)

#:# model
regr_task = makeRegrTask(data = skin_seg, target = "V1")
regr_lrn = makeLearner("regr.rpart", par.vals = list(maxdepth = 5))

#:# hash 
#:# 3b3b244bb8c811eee2435d534406befe
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse,rmse,mae,rsq))
er <- r$aggr
er

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
