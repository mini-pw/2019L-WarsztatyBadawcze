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
#:# 1a235eaf14ddf2d90f2b5c9519772786
hash <- digest(c("abalone-sex", "caret", "rda", cvx$bestTune))
hash

#:# audit
Acc <- cvx$results$Accuracy
measures <- list("Acc" = Acc)
measures

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
