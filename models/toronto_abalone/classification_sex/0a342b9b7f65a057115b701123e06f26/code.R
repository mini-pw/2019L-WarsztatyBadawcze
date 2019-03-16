#:# libraries
library(digest)
library(mlr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv("https://raw.githubusercontent.com/mini-pw/2019L-WarsztatyBadawcze_zbiory/master/toronto_abalone/abalone.csv")
head(dataset)

#:# preprocessing
head(dataset)

#:# model
train_control <- trainControl(method = "cv", number = 5)
cvx <- train(sex ~ ., data = dataset, method = "rda", tuneGrid = expand.grid(list(gamma = 0, lambda = 1)),
             trControl = train_control)

#:# hash 
#:# 0a342b9b7f65a057115b701123e06f26
hash <- digest(list(sex ~ ., dataset, "rda", expand.grid(list(gamma = 0, lambda = 1))))
hash

#:# audit
Acc <- cvx$results$Accuracy
measures <- list("acc" = Acc)
measures

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
