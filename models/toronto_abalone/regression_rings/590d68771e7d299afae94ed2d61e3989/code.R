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
cvx <- train(sex ~ ., data = dataset, method = "icr", tuneGrid = expand.grid(list(n.comp = 3)),
             trControl = train_control)

#:# hash 
#:# b76c813d89575869bda5b4178fe52c88
hash <- digest(c("abalone-rings", "caret", "icr", cvx$bestTune))
hash

#:# audit
RMSE <-regr_rf$results$RMSE
MSE <- RMSE^2
MAE <-regr_rf$results$MAE
R2 <- regr_rf$results$Rsquared
measures <- list("MSE" = MSE, "RMSE" = RMSE, "MAE" = MAE, "R2" = R2)
measures

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
