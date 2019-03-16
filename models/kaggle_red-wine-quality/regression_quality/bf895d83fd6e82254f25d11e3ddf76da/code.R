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
regr_rf <- train(quality ~ ., data = df, method = "rf", tuneGrid = expand.grid(
  mtry = 4),
  trControl = train_control)

#:# hash 
#:# bf895d83fd6e82254f25d11e3ddf76da
hash <- digest(c("winequality-red_drinks", "caret", "rf", regr_rf$bestTune))
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
