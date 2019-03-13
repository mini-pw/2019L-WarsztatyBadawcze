#:# libraries
library(OpenML)
library(caret)
library(digest)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
skin_segmentation <- getOMLDataSet(data.id = 1502)
skin_segmentation <- skin_segmentation$data

#:# model
regr_lm <- train(V3 ~ ., data = skin_segmentation, method = "lm", tuneGrid = expand.grid(
  intercept=TRUE))

#:# hash 
#:# 55e054cbff6cc8c168b267c0580d2f9f
hash <- digest(list(V3 ~ ., skin_segmentation, "lm", expand.grid(
  intercept=TRUE)))

#:# audit
train_control <- trainControl(method="cv", number=5)
regr_lm_cv <- train(V3 ~ ., data = skin_segmentation, method = "lm", tuneGrid = expand.grid(
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
