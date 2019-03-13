#:# libraries
library(digest)
library(OpenML)
library(caret)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
skin_seg <- getOMLDataSet(data.id = 1502)
skin_seg <- skin_seg$data

#:# preprocessing
head(skin_seg)

#:# model
regr_lrn <- caret::train(V1 ~ ., data = skin_seg, method = "lm", tuneGrid = expand.grid(
  intercept=TRUE))

#:# hash 
#:# 99ea59540178c3e746ab14f279ae8046
hash <- digest(regr_lrn)

#:# audit
train_control <- trainControl(method="cv", number=5)
regr_lrn_cv <- caret::train(V1 ~ ., data = skin_seg, method = "lm", tuneGrid = expand.grid(intercept=TRUE),trControl=train_control)
RMSE <-regr_lrn_cv$results$RMSE
MSE <- RMSE^2
MSE <- data.frame(MSE=MSE)
result <- regr_lrn_cv$results[c(2,3,4)]
result <- cbind(result,MSE)

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
