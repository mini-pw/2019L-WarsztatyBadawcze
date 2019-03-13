#:# libraries
library(digest)
library(OpenML)
library(mlr)


#:# config
set.seed(1)

#:# data
data_ <- read.csv(url("https://raw.githubusercontent.com/mini-pw/2019L-WarsztatyBadawcze_zbiory/master/kaggle_suicide-rates-overview-1985-to-2016/data.csv"))
data <- data_
head(data)

#:# preprocessing
data$HDI.for.year <- NULL
data$suicides_no <- NULL
data$country.year <- NULL
data$generation <- NULL
data$gdp_for_year.... <- NULL
data$suicides100k_pop <-data$suicides100k_pop/max(data$suicides100k_pop)
#data$population <- NULL
data <- data[sample(nrow(data), 1000), ]


head(data)

#:# model
task <- makeRegrTask(id = "reg_suic", data = data, target = "suicides100k_pop")
task <- createDummyFeatures(obj = task)
#regr_lrn = makeLearner("regr.lm")
learner <- makeLearner("regr.evtree")

#:# hash 
#:# 06c2a21476cc3c9ae7d1dbc350457486
list_to_hash <- list(task, learner)
hash <- digest(list_to_hash)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(learner, task, cv)
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo_", hash,".txt"))
sessionInfo()
sink()