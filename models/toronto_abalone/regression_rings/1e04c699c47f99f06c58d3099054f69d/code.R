#:# libraries
library(digest)
library(mlr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv("https://raw.githubusercontent.com/mini-pw/2019L-WarsztatyBadawcze_zbiory/master/toronto_abalone/abalone.csv")
head(dataset)

#:# preprocessing
head(dataset)

#:# model
train_control <- trainControl(method = "cv", number = 5)
cvx <- train(rings ~ ., data = dataset, method = "icr", tuneGrid = expand.grid(list(n.comp = 3)),
             trControl = train_control)

#:# hash 
#:# 1e04c699c47f99f06c58d3099054f69d
hash <- digest(list(rings ~ ., dataset, "icr", expand.grid(list(n.comp = 3))))
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
