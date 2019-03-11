#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(randomForestSRC)

#:# config
set.seed(997)

#:# data
haberman <- getOMLDataSet(data.id = 43L)
haberman <- haberman$data

#:# preprocessing
head(haberman)

#:# model
classif_task = makeClassifTask(data = haberman, target = "Survival_status")
classif_lrn = makeLearner("classif.randomForestSRC", predict.type = "prob")

#:# hash 
#:# 2e254a9fa09341ce4c29d4c9c83ca9d9
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tpr, tnr, f1, ppv))
er <- r$aggr
er

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
