#:# libraries
library(digest)
library(OpenML)
library(caret)
library(readr)
library(dplyr)

#:# config
set.seed(1)

#:# data
enc <- guess_encoding("winequality-red.csv", n_max = 10000)[[1]]
df <- as.data.frame(read_csv("winequality-red.csv", locale = locale(encoding = enc[1])))
head(df)

#:# preprocessing
head(df)

#:# model
train_control <- trainControl(method="cv", number=5)
set.seed(1)
regr_rf <- train(quality ~., data = df, method = "rf", tuneGrid = expand.grid(mtry = 4), trControl = train_control)

#:# hash 
#:# 5ca1382e2db158d4bd18e43dc91441dd
hash <- digest(list(quality ~ ., df, "rf", expand.grid(mtry = 4)))
hash

#:# audit
RMSE <-regr_rf$results$RMSE
MSE <- RMSE^2
MAE <-regr_rf$results$MAE
R2 <- regr_rf$results$Rsquared
measures <- list("mse" = MSE, "rmse" = RMSE, "mae" = MAE, "r2" = R2)
measures

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
