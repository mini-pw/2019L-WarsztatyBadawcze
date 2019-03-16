#:# libraries
library(caret)
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
data <- getOMLDataSet(data.id = 472L)
head(df)
df <- data$data

#:# preprocessing
head(df)

#:# model
train_control <- trainControl(method="cv", number=5)
regr_rf <- train(TIME ~ ., data = df, method = "ranger", tuneGrid = expand.grid(
  mtry = 3, 
  splitrule = "variance",
  min.node.size = 5))
#:# hash
#:# eddc80da42940ee05ed92bea2fa85b15
hash <- digest(list(TIME ~ ., df, "ranger", expand.grid(
  mtry = 3, 
  splitrule = "variance",
  min.node.size = 5)))
hash

#:# audit
train_control <- trainControl(method="cv", number=5)
regr_rf_cv <- train(TIME ~ ., data = df, method = "ranger", tuneGrid = expand.grid(
                                                                                        mtry = 3, 
                                                                                        splitrule = "variance",
                                                                                        min.node.size = 5),
                                                                                        trControl = train_control,
                                                                                        metric = "RMSE")

print(regr_rf_cv)
results <-regr_rf_cv$results
results


#:# session_info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()