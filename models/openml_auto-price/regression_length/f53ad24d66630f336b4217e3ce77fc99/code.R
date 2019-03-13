#:# libraries
library(OpenML)
library(caret)
library(digest)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
auto_price <- getOMLDataSet(data.id = 745)
auto <- auto_price$data

#:# model
regr_lm <- train(length ~ ., data = auto, method = "lm", tuneGrid = expand.grid(
  intercept=TRUE))

#:# hash 
#:# f53ad24d66630f336b4217e3ce77fc99
hash <- digest(regr_lm)

#:# audit
train_control <- trainControl(method="cv", number=5)
regr_lm_cv <- train(length ~ ., data = auto, method = "lm", tuneGrid = expand.grid(
  intercept=TRUE),trControl=train_control)
RMSE <-regr_lm_cv$results$RMSE
MSE <- RMSE^2
MSE <- data.frame(MSE=MSE)
result <- regr_lm_cv$results[c(2,3,4)]
result <- cbind(result,MSE)

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()