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
regr_task <- makeRegrTask(id="task", data = kids, target = "Grades")
regr_lrn <- makeLearner("regr.rpart")



#:# hash 
hash <- digest(list(regr_task, regr_lrn))
hash


#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn,regr_task,cv)
measures <- r$aggr
measures

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
