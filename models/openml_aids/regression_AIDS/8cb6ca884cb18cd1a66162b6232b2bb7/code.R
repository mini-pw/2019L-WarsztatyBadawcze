#:# libraries
library(OpenML)
library(caret)
library(digest)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
aids <- getOMLDataSet(data.id = 346)
aids <- aids$data

#:# model
regr_lm <- train(AIDS ~ ., data = aids, method = "lm", tuneGrid = expand.grid(
  intercept=TRUE))

#:# hash 
#:# 8cb6ca884cb18cd1a66162b6232b2bb7
hash <- digest(regr_lm)

#:# audit
train_control <- trainControl(method="cv", number=5)
regr_lm_cv <- train(AIDS ~ ., data = aids, method = "lm", tuneGrid = expand.grid(
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