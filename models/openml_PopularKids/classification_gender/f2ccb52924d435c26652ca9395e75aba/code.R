#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1233)


#:# data
popularKids <- getOMLDataSet(data.id = 1100L)
kids <- popularKids$data

#:# preprocessing
head(kids)
summary(kids)

#:# model
classif_task <- makeClassifTask(id="kids", data = kids, target = "Gender")
classif_lrn <- makeLearner("classif.randomForest", predict.type = 'prob',par.vals = list(ntree=750))


#:# hash 
hash <- digest(classif_lrn)
hash


#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn,classif_task,cv, measures = list(acc, auc))
measures <- r$aggr
measures

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
