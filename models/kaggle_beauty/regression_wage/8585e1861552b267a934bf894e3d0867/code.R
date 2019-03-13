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
regr_task = makeRegrTask(id = "b1", data = beauty, target = "wage")
regr_lrn = makeLearner("regr.lm")

#:# hash 
#:# "8585e1861552b267a934bf894e3d0867"
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv)
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()

