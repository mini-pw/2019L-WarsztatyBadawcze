#:# libraries
library(OpenML)
library(caret)
library(digest)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
sleep <- getOMLDataSet(data.id = 205L)
sleep <- sleep$data

#:# preprocessing
sleep <- na.omit(sleep)

#:# model
regr_lm <- train(total_sleep ~ ., data = sleep, method = "bayesglm")

#:# hash 
#:# e1fbc409fc87a594b761e000ebd7607c
hash <- digest(list(total_sleep ~ ., data = sleep, method = "bayesglm", trControl=train_control))
hash

#:# audit
train_control <- trainControl(method="cv", number=5)
regr_lm_cv <- train(total_sleep ~ ., data = sleep, method = "bayesglm", trControl=train_control)

RMSE <-regr_lm_cv$results$RMSE
MSE <- RMSE^2
MAE <-regr_lm_cv$results$MAE
R2 <- regr_lm_cv$results$Rsquared
measures <- list("MSE" = MSE, "RMSE" = RMSE, "MAE" = MAE, "R2" = R2)
measures

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()