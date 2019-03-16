#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
beauty <- read.csv("https://raw.githubusercontent.com/mini-pw/2019L-WarsztatyBadawcze_zbiory/master/kaggle_beauty/beauty.csv")
head(beauty)

#:# preprocessing

#:# model
classif_task = makeClassifTask(id = "b2", data = beauty, target = "married")
classif_lrn = makeLearner("classif.binomial", predict.type = "prob")

#:# hash 
#:# 471af4c5e74bef746493fe8582a7a3b8
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc))
ACC = r$aggr
ACC

#:# session info
sink(paste0("sessionInfo2.txt"))
sessionInfo()
sink()

