#:# libraries
library(data.table)
library(digest)
library(caret)
library(DALEX)
library(party)
library(glmnet)
library(plyr)

#:# config
set.seed(123)

#:# data
dataset <- read.csv("readyToModel.csv")
# head(dataset)

#:# preprocessing
# dataset <- data.table(dataset)
# dataset <- dataset[is.na(performance.acc)==FALSE,]
# dataset <- dataset[,list(dataset_id,task_id,performance.acc,library,model_name)]
# dataset$data_task_id <- paste(dataset$dataset_id,tolower(dataset$task_id),sep = "_")
# dataset <- dataset[,list(data_task_id,performance.acc,library,model_name)]
# dataset$data_task_id <- as.factor(dataset$data_task_id)
# dataset$library <- as.factor(tolower(dataset$library))
# dataset$model_name <- as.factor(tolower(dataset$model_name))
# head(dataset)
# write.csv(dataset,"readyToModel.csv")

#:# model glmnet caret
regr_glm <- train(performance.acc ~ ., data = dataset, method = "glmnet",
                  tuneGrid = expand.grid(alpha = 0, lambda = 0.5))

#:# audit glmnet caret
# train_control <- trainControl(method="cv", number=5)
# regr_glm_cv <- train(performance.acc ~ ., data = dataset, method = "glmnet",
#                         tuneGrid = expand.grid(alpha = 0, lambda = 0.5),
#                         metric = "RMSE",
#                         trControl = train_control)
# print(regr_glm_cv)
# 
# lMSE <- regr_glm_cv$results[3]^2
# lMSE
# lRMSE <- regr_glm_cv$results[3]
# lRMSE
# lMAE <- regr_glm_cv$results[5]
# lMAE
# lR2 <- regr_glm_cv$results[4]
# lR2


#:# model cforest caret
regr_cforest <- train(performance.acc ~ ., data = dataset, method = "cforest",
                      tuneGrid = expand.grid(mtry=77))

#:# audit cforest caret
# train_control <- trainControl(method="cv", number=5)
# regr_cforest_cv <- train(performance.acc ~ ., data = dataset, method = "cforest",
#                             tuneGrid = expand.grid(mtry=77),
#                         metric = "RMSE",
#                         trControl = train_control)
# print(regr_cforest_cv)
# 
# fMSE <- regr_cforest_cv$results[2]^2
# fMSE
# fRMSE <- regr_cforest_cv$results[2]
# fRMSE
# fMAE <- regr_cforest_cv$results[4]
# fMAE
# fR2 <- regr_cforest_cv$results[3]
# fR2

#:# model lm caret
regr_lm <- train(performance.acc ~ ., data = dataset, method = "lm")

#:# audit lm caret
# train_control <- trainControl(method="cv", number=5)
# regr_lm_cv <- train(performance.acc ~ ., data = dataset, method = "lm",
#                      metric = "RMSE",
#                      trControl = train_control)
# print(regr_lm_cv)


#:# model forest caret
regr_forest <- train(performance.acc ~ ., data = dataset, method = "rf",
                      tuneGrid = expand.grid(mtry=77))

#:# audit forest caret
# train_control <- trainControl(method="cv", number=5)
# regr_forest_cv <- train(performance.acc ~ ., data = dataset, method = "rf",
#                          tuneGrid = expand.grid(mtry=77),
#                          metric = "RMSE",
#                          trControl = train_control)
# print(regr_forest_cv)


#:# model boost caret
regr_boost <- train(performance.acc ~ ., data = dataset, method = "xgbTree")

#:# audit boost caret
# train_control <- trainControl(method="cv", number=5)
# regr_boost_cv <- train(performance.acc ~ ., data = dataset, method = "xgbTree",
#                          metric = "RMSE",
#                          trControl = train_control)
# print(regr_boost_cv)


#:# explainers
explainer_glm <- explain(regr_glm, 
                        data = dataset[,-2], y = dataset$performance.acc,label = "glmnet")


explainer_crf <- explain(regr_cforest, 
                        data = dataset[,-2], y = dataset$performance.acc,label = "cforest")


explainer_lm <- explain(regr_lm, 
                         data = dataset[,-2], y = dataset$performance.acc,label = "lm")


explainer_rf <- explain(regr_forest, 
                         data = dataset[,-2], y = dataset$performance.acc,label = "forest")


explainer_bo <- explain(regr_boost, 
                         data = dataset[,-2], y = dataset$performance.acc,label = "boost")


mp_glm <- model_performance(explainer_glm)
mp_crf <- model_performance(explainer_crf)
mp_lm <- model_performance(explainer_lm)
mp_rf <- model_performance(explainer_rf)
mp_bo <- model_performance(explainer_bo)

vi_glm <- variable_importance(explainer_glm, loss_function = loss_root_mean_square)

vi_crf <- variable_importance(explainer_crf, loss_function = loss_root_mean_square)

vi_lm <- variable_importance(explainer_lm, loss_function = loss_root_mean_square)

vi_rf <- variable_importance(explainer_rf, loss_function = loss_root_mean_square)

vi_bo <- variable_importance(explainer_bo, loss_function = loss_root_mean_square)


# plot(mp_glm, mp_crf, mp_lm, mp_rf, mp_bo)
# plot(mp_glm, mp_crf, mp_lm, mp_rf, mp_bo, geom = "boxplot")
# plot(vi_glm, vi_crf, vi_lm, vi_rf, vi_bo)

