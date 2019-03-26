library(mlr)
library(dplyr)
library(funModeling)
library(DataExplorer)



# zebranie danych ---------------------------------------------------------
source("../../scripts/MichaloScraper2000.R")
oldwd <- getwd()
setwd("../../models")
out2 <- scrape(c("classif.ranger","classif.randomForest" ,"classif.cforest","classif.randomForestSRC","RandomForestClassifier","classif.RRF","classif.h2o.randomForest"),
               c("acc"), 
               list(c("num.trees", "ntree","n_estimators","ntrees")), 
               "classification", 
               pathbase = getwd())
setwd(oldwd)

# przygotowanie ramki -----------------------------------------------------
out2 <- out2 %>% mutate(percentage_of_instances_with_missing_values=number_of_instances_with_missing_values/number_of_instances,
                percentage_of_missing_values=number_of_missing_values/(number_of_features*number_of_instances))
out2 <- drop_columns(out2,c("number_of_instances_with_missing_values","number_of_missing_values","target.ncats"))
out <- out2

df_stat <- df_status(out)
to_drop <- df_stat %>% filter(p_na>50 | p_zeros==100) %>% select(variable)
out <- drop_columns(out,unlist(to_drop))
out <- out %>% mutate(target.type=replace(target.type,target.type %in% c("factor","nominal"),"categorical")) %>% as.data.frame()
out$performance.acc <- as.numeric(as.character(out$performance.acc))
# out$performance.auc <- as.numeric(as.character(out$performance.auc))
# out$performance.f1 <- as.numeric(as.character(out$performance.f1))
out$parameters.num.trees <- as.numeric(as.character(out$parameters.num.trees))
df_stat <- df_status(out)
# one hot enc -------------------------------------------------------------
library(vtreat)
library(magrittr)

vars <- c("model_name","target.type")

treatplan <- designTreatmentsZ(out, vars)

scoreFrame <- treatplan %>%
  use_series(scoreFrame) %>%
  select(varName, origName, code)

newvars <- scoreFrame %>%
  filter(code %in% c("clean", "lev")) %>%
  use_series(varName)


out <- cbind(out,prepare(treatplan, out, varRestriction = newvars))
out$model_name <- NULL
out$target.type <- NULL

out <- drop_columns(out,c("target.name"))
out$id <- as.factor(out$id)
out$target.name <- as.factor(out$target.name)
out$model_name <- as.factor(out$model_name)
out$target.type <- as.factor(out$target.type)
out$target.largestCatSize <- NULL
out$target.smallestCatSize <- NULL

# random forest -----------------------------------------------------------

        
set.seed(123,"L'Ecuyer")
regr_task <- makeRegrTask(id="task",data=select(out,-id, -target.name),target="performance.acc")


learner_rf <- makeLearner("regr.randomForest", par.vals = list(ntree=100))

cv <- makeResampleDesc("CV", iters = 5)
r <- resample(learner_rf, regr_task, cv, measures = list(mse,rmse,mae,rsq))
measure <- r$aggr
measure

# gbm --------------------------------------------------------

learner_gbm <- makeLearner("regr.gbm")

cv <- makeResampleDesc("CV", iters = 5)
r <- resample(learner_gbm, regr_task, cv, measures = list(mse,rmse,mae,rsq))
measure <- r$aggr
measure


# decision tree -----------------------------------------------------------


learner_rpart <- makeLearner("regr.rpart",par.vals = list(minsplit=2))

cv <- makeResampleDesc("CV", iters = 5)
r <- resample(learner_rpart, regr_task, cv, measures = list(mse,rmse,mae,rsq))
measure <- r$aggr
measure

# xgboost -----------------------------------------------------------------

learner_xgb <- makeLearner("regr.xgboost")

cv <- makeResampleDesc("CV", iters = 5)
r <- resample(learner_xgb, regr_task, cv, measures = list(mse,rmse,mae,rsq))
measure <- r$aggr
measure

# knn -----------------------------------------------------------------

learner_knn <- makeLearner("regr.rknn")

cv <- makeResampleDesc("CV", iters = 5)
r <- resample(learner_knn, regr_task, cv, measures = list(mse,rmse,mae,rsq))
measure <- r$aggr
measure

# por?wnanie modeli -------------------------------------------------------

library(DALEX)

regr_rf <- train(learner_rf,regr_task)
regr_rpart <- train(learner_rpart,regr_task)
regr_gbm <- train(learner_gbm,regr_task)
# regr_xgb <- train(learner_xgb,regr_task)


custom_predict <- function(object, newdata) {pred <- predict(object, newdata=newdata)
response <- pred$data$response
return(response)}

explainer_regr_rf <- explain(regr_rf, data=out, y=out$performance.acc, predict_function = custom_predict, label="rf")
explainer_regr_rpart <- explain(regr_rpart, data=out, y=out$performance.acc, predict_function = custom_predict, label="rpart")
explainer_regr_gbm <- explain(regr_gbm, data=out, y=out$performance.acc, predict_function = custom_predict, label="gbm")
# explainer_regr_xgb <- explain(regr_xgb, data=out, y=out$performance.acc, predict_function = custom_predict, label="xgb")

mp_regr_rf <- model_performance(explainer_regr_rf)
mp_regr_rpart <- model_performance(explainer_regr_rpart)
mp_regr_gbm <- model_performance(explainer_regr_gbm)
# mp_regr_xgb <- model_performance(explainer_regr_xgb)

plot(mp_regr_rf,mp_regr_rpart,mp_regr_gbm)

plot(mp_regr_rf,mp_regr_rpart,mp_regr_gbm,geom="boxplot")

vi_regr_rf <- variable_importance(explainer_regr_rf, loss_function = loss_root_mean_square)
vi_regr_rpart <- variable_importance(explainer_regr_rpart, loss_function = loss_root_mean_square)
vi_regr_gbm <- variable_importance(explainer_regr_gbm, loss_function = loss_root_mean_square)
# vi_regr_xgb <- variable_importance(explainer_regr_xgb, loss_function = loss_root_mean_square)

plot(vi_regr_rf,vi_regr_rpart,vi_regr_gbm)

pdp_regr_rf  <- variable_response(explainer_regr_rf, variable =  "performance.acc", type = "pdp")
pdp_regr_rpart  <- variable_response(explainer_regr_rpart, variable =  "performance.acc", type = "pdp")
pdp_regr_gbm <- variable_response(explainer_regr_gbm, variable =  "performance.acc", type = "pdp")
# pdp_regr_xgb  <- variable_response(explainer_regr_xgb, variable =  "performance.acc", type = "pdp")
plot(pdp_regr_rf,pdp_regr_rpart,pdp_regr_gbm)


library(auditor)
library(randomForest)
model_rf <- randomForest(performance.acc~.,data=select(out,-id),ntree=1000)
audit_rf <- audit(model_rf,out,out$performance.acc)

model_rpart <- rpart::rpart(performance.acc~.,data=out,control = rpart::rpart.control(minsplit = 5))
audit_rpart <- audit(model_rpart,out,out$performance.acc)

plot(audit_rf, type = "Prediction", variable = "performance.acc")
plot(audit_rpart,audit_rf, type = "Prediction", variable = "performance.acc")
new_score <- function(object) sum((object$residuals)^3)
rf_mp <- modelPerformance(audit_rf,  
                          scores = c("MAE", "MSE", "REC", "RROC"), 
                          new.score = new_score)
rf_mp


# test na nowych danych ---------------------------------------------------

n <- nrow(out)

set.seed(74239)

splitind <- rep(1, n)
traininddnum <- floor(n*0.25)
testind <- sample(1:n, traininddnum)
splitind[testind] <- 2
splitind
splitlist <- split(out, splitind)

data_train <- splitlist$`1`
data_test<- splitlist$`2`

model_rf <- randomForest(performance.acc~.,data=data_train,ntree=100)
predicted_mi2_rf <- predict(model_rf, data_test)
sqrt(mean((predicted_mi2_rf - data_test$performance.acc)^2))

cbin(pred=predicted_mi2_rf,real=data_test$performance.acc)


explainer_regr_rf <- explain(model_rf, data=data_test, y=data_test$performance.acc, predict_function = custom_predict, label="rf")
variable_importance(explainer_regr_rf, loss_function = loss_root_mean_square)
