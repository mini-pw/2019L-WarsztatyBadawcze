#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(gbm)


#:# config
set.seed(1)

#:# data
Sea_full <- getOMLDataSet(data.id = 161L)
Sea <- Sea_full$data
head(Sea)

#:# preprocessing
head(Sea)

#:# model
regr_task = makeRegrTask(id = "task", data = Sea, target = "attrib1")
regr_lrn = makeLearner("regr.gbm", par.vals = list(n.trees = 500, interaction.depth = 3))

#:# hash 
#:# a70b40e04322d838c572fc281fe4aa45
hash <- digest(list(regr_task, regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse,rmse,mae,rsq))
r$aggr


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
