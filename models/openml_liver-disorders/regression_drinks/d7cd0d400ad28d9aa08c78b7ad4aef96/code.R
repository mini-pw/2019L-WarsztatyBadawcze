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
set.seed(1)
regr_rf <- train(drinks ~ ., data = df, method = "rf", tuneGrid = expand.grid(mtry = 3),
    trControl = train_control)

#:# hash 
#:# d7cd0d400ad28d9aa08c78b7ad4aef96
hash <- digest(list(drinks ~ ., df, "rf", expand.grid(mtry = 3)))
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
