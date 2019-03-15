setwd("/home/samba/jastrzebskib/2019L-WarsztatyBadawcze/models/kaggle_predicting-a-pulsar-star/classification_target_class/565fd85e198238212ccb60d64ce99635")
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
#:# 5661bff4391e081ad481e455c59ba439
hash <- digest(list(target_class ~ ., dataset, "kknn", train_control))
hash

#:# audit

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
