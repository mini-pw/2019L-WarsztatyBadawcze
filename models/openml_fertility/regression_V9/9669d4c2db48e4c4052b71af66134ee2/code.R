#:# libraries
library(digest)
library(OpenML)
library(caret)
library(dplyr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
fertility_dat <- getOMLDataSet(data.id = 1473)
fertility <- fertility_dat$data
head(fertility)

#:# preprocessing
head(fertility)

#:# model
train_control <- trainControl(method="cv", number = 5)
regr_rf <- train(V9 ~., data = fertility, method = "rf", tuneGrid = expand.grid(
  mtry = 3),
  trControl = train_control)
regr_rf$times <- NULL

#:# hash
#:# 9669d4c2db48e4c4052b71af66134ee2
hash <- digest(regr_rf)
hash

#:# audit
RMSE <- regr_rf$results$RMSE
MSE <- RMSE^2
MAE <- regr_rf$results$MAE
R2 <- regr_rf$results$Rsquared
measures <- list("RMSE" = RMSE, "MSE" = MSE, "MAE" = MAE, "R2" = R2)
measures
#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()