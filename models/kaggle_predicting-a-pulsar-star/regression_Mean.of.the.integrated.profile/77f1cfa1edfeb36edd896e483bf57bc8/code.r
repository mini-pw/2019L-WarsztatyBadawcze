setwd("C:/Users/Piotr/Documents/Bogdan/Warsztaty badawcze/pd3/regression/565fd85e198238212ccb60d64ce99635")
#:# libraries
library(digest)
library(OpenML)
library(caret)
library(readr)
library(dplyr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv("pulsar_stars.csv")[,-9]
head(dataset)

#:# preprocessing
head(dataset)

#:# model
train_control <- trainControl(method="cv", number=5)
set.seed(1)
regr_rf <- train(Mean.of.the.integrated.profile ~ ., data = dataset, method = "ranger",
  trControl = train_control)

#:# hash 
#:# 77f1cfa1edfeb36edd896e483bf57bc8
hash <- digest(c("pulsar_stars", "caret", "ranger", regr_rf$bestTune))
hash

#:# audit

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
