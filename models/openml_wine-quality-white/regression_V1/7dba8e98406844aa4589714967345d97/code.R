#:# libraries
library(digest)
library(OpenML)
library(caret)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
wine <- getOMLDataSet(data.id = 40498L)
wine <- wine$data
head(wine)

#:# preprocessing
head(wine)

#:# model
regr_rf <- train(V1 ~ ., data = wine, method = "ranger", tuneGrid = expand.grid(
  mtry = 3, 
  splitrule = "variance",
  min.node.size = 5))

#:# hash 
#:# 7dba8e98406844aa4589714967345d97
hash <- digest(list(V1 ~ ., data = wine, method = "ranger", tuneGrid = expand.grid(
  mtry = 3, 
  splitrule = "variance",
  min.node.size = 5)))
hash

#:# audit
set.seed(123, "L'Ecuyer")
train_control <- trainControl(method="cv", number=5)
regr_rf_cv <- train(V1 ~ ., data = wine, method = "ranger", tuneGrid = expand.grid(
  mtry = 3, 
  splitrule = "variance",
  min.node.size = 5),
  trControl = train_control)

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