#:# libraries
library(digest)
library(OpenML)
library(caret)

#:# config
set.seed(1)

#:# data
liver_disorders <- getOMLDataSet(data.id = 8L)
df <- liver_disorders$data
head(df)

#:# preprocessing
head(df)

#:# model
train_control <- trainControl(method="cv", number=5)
regr_rf <- caret::train(mcv ~ ., data = df, method = "rf", tuneGrid = expand.grid(
  mtry = 4),
  trControl = train_control)

#:# hash 
#:# 14643142a46756daa57ecc08cc9ce9c6
hash <- digest(list(mcv ~ ., df, "rf", expand.grid(mtry = 4), trControl = train_control))
hash

#:# audit
RMSE <-regr_rf$results$RMSE
MSE <- RMSE^2
MAE <-regr_rf$results$MAE
R2 <- regr_rf$results$Rsquared
measures <- list("mse" = MSE, "rmse" = RMSE, "mae" = MAE, "rsq" = R2)
measures

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
