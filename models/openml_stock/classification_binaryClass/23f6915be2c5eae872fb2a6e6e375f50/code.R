#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(rknn)

#:# config
set.seed(1233,"L'Ecuyer")


#:# data
stockDataSet <- getOMLDataSet(data.id = 841L)
stock <- stockDataSet$data

#:# preprocessing
head(stock)
summary(stock)

#:# model
classif_task <- makeClassifTask(id="task", data = stock, target = "binaryClass")
classif_lrn <- makeLearner("classif.rknn",par.vals = list("k"=3,"mtry"=3, "seed"=13))


#:# hash 
#:# 23f6915be2c5eae872fb2a6e6e375f50
hash <- digest(list(classif_task,classif_lrn))
hash


#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn,classif_task,cv, measures = list(acc,tnr,tpr,ppv,f1))
perf <- as.list(rep(NA,6))
perf[c(1,3,4,5,6)] <- r$aggr     # bez AUC
names(perf) <- c("ACC","AUC", "Specificity","Recall","Precision","F1")
perf

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
