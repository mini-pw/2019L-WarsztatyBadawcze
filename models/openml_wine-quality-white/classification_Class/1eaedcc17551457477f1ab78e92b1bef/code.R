#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
dane <- getOMLDataSet(data.id = 40498L)
df <- dane$data
head(df)

#:# preprocessing
head(df)

#:# model
classif_task <- makeClassifTask(id="classif", data = df, target = "Class")
classif_lrn <- makeLearner("classif.fnn")

#:# hash 
#:# 1eaedcc17551457477f1ab78e92b1bef
hash <- digest(list(classif_task,classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn,classif_task,cv,measures = list(acc))
r$aggr


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
