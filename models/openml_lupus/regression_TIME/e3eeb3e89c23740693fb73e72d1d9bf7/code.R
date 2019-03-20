#:# libraries
library(OpenML)
library(caret)
library(digest)

#:# config
set.seed(1)

#:# data
lupus <- getOMLDataSet(data.id = 472)
lupus <- lupus$data

#:# model
regr_lm <- train(TIME ~ ., data = lupus, method = "lm", tuneGrid = expand.grid(
  intercept=TRUE))

#:# hash 
#:# e3eeb3e89c23740693fb73e72d1d9bf7
hash <- digest(list(TIME ~ .,lupus,'lm',expand.grid(
  intercept=TRUE)))

#:# audit
train_control <- trainControl(method="cv", number=5)
regr_lm_cv <- train(TIME ~ ., data = lupus, method = "lm", tuneGrid = expand.grid(
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