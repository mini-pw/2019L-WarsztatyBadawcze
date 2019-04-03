library(DALEX)
library(auditor)
library(randomForest)
library(h2o)
library(mlr)
library(breakDown)
library(dummies)

data <- out

modelsFull <- cbind(out, dummy(out$id, sep = "_"))
modelsFull <- cbind(modelsFull, dummy(out$model_name, sep = "_"))
modelsFull <- cbind(modelsFull, dummy(out$added_by, sep = "_"))

modelsFull <- dplyr::select(modelsFull, -c("id", "model_name", "added_by"))
colnames(modelsFull) <- make.names(names(modelsFull),unique = F)
modelsFull$performance.acc <- as.numeric(as.character(modelsFull$performance.acc))
modelsFull <- na.omit(modelsFull)

models <- sample_frac(modelsFull, 0.6)
modelsTest <- base::setdiff(models, modelsFull)

# help
custom_predict <- function(object, newdata) {pred <- predict(object, newdata=newdata)
  response <- pred$data$response
  return(response)}


# linear model
models_lm_model <- lm(performance.acc ~ ., data = models)
# MSE
predicted_mi2_lm <- predict(models_lm_model, modelsTest)
sqrt(mean((predicted_mi2_lm - modelsTest$performance.acc)^2))

# random forest
set.seed(59)
models_rf_model <- randomForest(performance.acc ~ ., data = models)
# MSE
predicted_mi2_rf <- predict(models_rf_model, modelsTest)
sqrt(mean((predicted_mi2_rf - modelsTest$performance.acc)^2))

# deep learnig in h2o
models_task <- makeRegrTask(id = "ap", data = models, target = "performance.acc")
models_dl_lrn <- makeLearner("regr.h2o.deeplearning")
regr_dl <- mlr::train(models_dl_lrn, models_task)

# knn
models_task <- makeRegrTask(id = "ap", data = models, target = "performance.acc")
models_knn_lrn <- makeLearner("regr.kknn")
regr_knn <- mlr::train(models_knn_lrn, models_task)

# svm
models_task <- makeRegrTask(id = "ap", data = models, target = "performance.acc")
models_svm_lrn <- makeLearner("regr.svm")
regr_svm <- mlr::train(models_svm_lrn, models_task)

# create explainers and audit functions
explainer_lm <- explain(models_lm_model, 
                        data = dplyr::select(modelsTest, -performance.acc), y = modelsTest$performance.acc)


explainer_rf <- explain(models_rf_model, 
                        data = dplyr::select(modelsTest, -performance.acc), y = modelsTest$performance.acc)


explainer_dl <- explain(regr_dl, data = dplyr::select(modelsTest, -performance.acc),
                        y=modelsTest$performance.acc, predict_function = custom_predict, label = "dl")


explainer_knn <- explain(regr_knn, data = dplyr::select(modelsTest, -performance.acc),
                        y=modelsTest$performance.acc, predict_function = custom_predict, label = "knn")


explainer_svm <- explain(regr_svm, data = dplyr::select(modelsTest, -performance.acc),
                         y=modelsTest$performance.acc, predict_function = custom_predict, label = "svm")


# Function model_performance() calculates predictions and residuals for validation dataset modelsTest.
mp_lm <- model_performance(explainer_lm)
mp_rf <- model_performance(explainer_rf)
mp_dl <- model_performance(explainer_dl)
mp_knn <- model_performance(explainer_knn)
mp_svm <- model_performance(explainer_svm)



plot(mp_lm, mp_rf, mp_dl, mp_knn, mp_svm)
plot(mp_lm, mp_rf, mp_dl, mp_knn, mp_svm, geom = "boxplot")

# Model agnostic variable importance is calculated by means of permutations. 
# We simply substract the loss function calculated for validation dataset with permuted values 
# for a single variable from the loss function calculated for validation dataset. 
vi_lm <- variable_importance(explainer_lm, loss_function = loss_root_mean_square)


vi_rf <- variable_importance(explainer_rf, loss_function = loss_root_mean_square)


plot(vi_rf)


# Partial Dependence Plots show the expected output condition on a selected variable
sv_rf  <- single_variable(explainer_rf, variable =  "number_of_instances", type = "pdp")
sv_lm  <- single_variable(explainer_lm, variable =  "number_of_instances", type = "pdp")
plot(sv_rf, sv_lm)




# Detailed models
library(auditor)
audit_lm <- audit(models_lm_model, 
                  data = modelsTest, y = modelsTest$performance.acc)
audit_rf <- audit(models_rf_model, 
                  data = modelsTest, y = modelsTest$performance.acc, label = "rf")

plot(audit_rf, type = "Prediction", variable = "performance.acc")

plot(audit_lm, type = "Prediction", variable = "performance.acc")



# Improved model

#Old one

# linear model
models_lm_model <- lm(performance.acc ~ ., data = models)
# MSE
predicted_mi2_lm <- predict(models_lm_model, modelsTest)
sqrt(mean((predicted_mi2_lm - modelsTest$performance.acc)^2))

# Improved one

nearZero <- caret::nearZeroVar(modelsFull)
improved <- modelsFull[, -nearZero]

models <- sample_frac(improved, 0.6)
modelsTest <- setdiff(models, improved)

# linear model
models_lm_model <- lm(performance.acc ~ ., data = models)
# MSE
predicted_mi2_lm <- predict(models_lm_model, modelsTest)
sqrt(mean((predicted_mi2_lm - modelsTest$performance.acc)^2))


#Variable IMP
rf <- randomForest(performance.acc ~ ., data=models)
varImpPlot(rf)

sortedImportance=order(-rf$importance[,1])
tops=rownames(rf$importance)[sortedImportance][1:15][1:15]

tops <- append(tops, "performance.acc")

models <- models[tops]
modelsTest <- models[tops]

models_lm_model <- lm(performance.acc ~ ., data = models)
# MSE
predicted_mi2_lm <- predict(models_lm_model, modelsTest)
sqrt(mean((predicted_mi2_lm - modelsTest$performance.acc)^2))

