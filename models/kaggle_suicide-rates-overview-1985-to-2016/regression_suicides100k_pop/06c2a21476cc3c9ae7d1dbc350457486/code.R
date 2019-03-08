#:# libraries
library(digest)
library(OpenML)
library(mlr)


#:# config
set.seed(1)

#:# data
data_ <- read.csv(url("https://raw.githubusercontent.com/k-sap/2019L-WarsztatyBadawcze_zbiory/master/kaggle_suicide-rates-overview-1985-to-2016/data.csv"))
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
regr_task = makeRegrTask(id = "reg_suic", data = data, target = "suicides100k_pop")
regr_task <- createDummyFeatures(obj = regr_task)
#regr_lrn = makeLearner("regr.lm")
regr_lrn = makeLearner("regr.evtree")

#:# hash 
#:# 06c2a21476cc3c9ae7d1dbc350457486
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv)
MSE <- r$aggr
MSE

#:# session info
sink(paste0("sessionInfo_", hash,".txt"))
sessionInfo()
sink()