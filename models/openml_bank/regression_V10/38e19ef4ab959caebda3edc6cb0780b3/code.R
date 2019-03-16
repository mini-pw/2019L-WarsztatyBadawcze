#:# libraries
library(OpenML)
library(caret)
library(digest)

#:# config
set.seed(1)

#:# data
bank <- getOMLDataSet(data.id = 1461)
bank <- bank$data

#:# model
regr_lm <- train(V10 ~ ., data = bank, method = "lm", tuneGrid = expand.grid(
  intercept=TRUE))

#:# hash 
#:# 38e19ef4ab959caebda3edc6cb0780b3
hash <- digest(list(V10 ~ .,bank,'lm',expand.grid(
  intercept=TRUE)))

#:# audit
train_control <- trainControl(method="cv", number=5)
regr_lm_cv <- train(V10 ~ ., data = bank, method = "lm", tuneGrid = expand.grid(
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