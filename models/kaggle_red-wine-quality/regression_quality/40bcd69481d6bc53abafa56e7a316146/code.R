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
train_control <- trainControl(method="cv", number=50)
set.seed(1)
regr_rf <- train(quality ~., data = df, method = "brnn", tuneGrid = expand.grid(neurons = 5), trControl = train_control)

#:# hash 
#:# 40bcd69481d6bc53abafa56e7a316146
hash <- digest(list(quality ~ ., df, "brnn", expand.grid(neurons = 50)))
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
