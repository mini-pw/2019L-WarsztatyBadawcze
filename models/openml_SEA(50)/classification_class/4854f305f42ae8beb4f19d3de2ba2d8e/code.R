#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
data <- getOMLDataSet(data.id = 161L)
df <- data$data
head(df)

#:# preprocessing
head(df)

#:# model
classif_task = makeClassifTask(id = "class", data = df, target = "class")
classif_lrn = makeLearner("classif.logreg", predict.type = "prob")

#:# hash 
#:# 4854f305f42ae8beb4f19d3de2ba2d8e
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
r$aggr


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()