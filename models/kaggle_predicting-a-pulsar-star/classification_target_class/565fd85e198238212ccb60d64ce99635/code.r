setwd("C:/Users/Piotr/Documents/Bogdan/Warsztaty badawcze/pd3/classification/8da9a1cc0f5ecfa8729f7412a93d05cc")
#:# libraries
library(digest)
library(OpenML)
library(caret)
library(readr)
library(dplyr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv("pulsar_stars.csv")
dataset$target_class <- as.factor(as.character(dataset$target_class))
head(dataset)

#:# preprocessing
head(dataset)

#:# model
train_control <- trainControl(method="cv", number=5)
set.seed(1)
regr_rf <- train(target_class ~ ., data = dataset, method = "kknn",
  trControl = train_control)

#:# hash 
#:# 565fd85e198238212ccb60d64ce99635
hash <- digest(c("pulsar_stars", "caret", "kknn", regr_rf$bestTune))
hash

#:# audit

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
