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
#:# e0ae5a9a07b95e41e81739b94d67735b
hash <- digest(list(AIDS ~ ., aids, "lm", expand.grid(
  intercept=TRUE)))

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
