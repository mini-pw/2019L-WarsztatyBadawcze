setwd("/home/samba/jastrzebskib/2019L-WarsztatyBadawcze/models/kaggle_predicting-a-pulsar-star/regression_Mean.of.the.integrated.profile/77f1cfa1edfeb36edd896e483bf57bc8")
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
#:# 61f01a1058d3d2a2f0cc0ae3061f94e4
hash <- digest(list(Mean.of.the.integrated.profile ~ ., dataset, "ranger",
                     train_control))
hash

#:# audit

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
