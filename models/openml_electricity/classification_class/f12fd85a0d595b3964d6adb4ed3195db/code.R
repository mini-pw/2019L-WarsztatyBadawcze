#:# libraries

library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
data <- getOMLDataSet(data.id = 151L)
head(df)
df <- data$data

#:# preprocessing
head(df)

#:# model
classif_task <- makeClassifTask(id = "el1", data = df, target = "class")
classif_lrn <- makeLearner("classif.randomForest", predict.type = "prob")

#:# hash
#:# f12fd85a0d595b3964d6adb4ed3195db
hash <- digest(classif_task)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc))
ACC <- r$aggr
ACC

#:# session_info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
