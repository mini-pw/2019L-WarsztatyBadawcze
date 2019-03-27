library(readr)
library(mlr)
library(DALEX)

# LEARNING AND test DATASETS

readr::read_csv("final_dataset.csv", col_types = cols(
  library = col_factor(),
  model_name = col_factor(),
  numberOfCategoricalFeatures = col_double(),
  numberOfNumericalFeatures = col_double(),
  meanUniqueNumericalValues = col_double(),
  meanUniqueCategoricalValues = col_double(),
  meanNumberMissing = col_double(),
  number_of_instances = col_double(),
  ACC = col_double()
)) -> df

df <- df[!is.na(df$meanUniqueNumericalValues), ] 
df <- df[!is.na(df$meanUniqueCategoricalValues), ] 

spl <- sample(1:nrow(df), nrow(df)%/%5)

learning <- df[-spl,]
test <- df[spl,]

# TRAINED MODEL

regr_task = makeRegrTask(id = "task", data = learning, target = "ACC")
regr_lrn = makeLearner("regr.bartMachine")

regr_gbm <- train(regr_lrn, regr_task)

# PREDICT ON TEST
regr_task_test = makeRegrTask(id = "task", data = test, target = "ACC")
predicted <- predict(regr_gbm, regr_task_test)
performance(predicted)

custom_predict <- function(object, newdata) {
    pred <- predict(object, newdata=newdata)
    response <- pred$data$response
    return(response)
}

explainer <- explain(regr_gbm,
                     data = test,
                     y=test$ACC,
                     predict_function = custom_predict,
                     label="Bart Machine")

# MODEL PERFORMANCE

mp <- model_performance(explainer)

plot(mp)
plot(mp, geom = "boxplot")

# VARIABLE IMPORTANCE

vi <- variable_importance(explainer, loss_function = loss_root_mean_square)

plot(vi)

# PARTIAL DEPENDENCE PLOT

# sv  <- single_variable(explainer, variable ="model_name", type = "pdp")

# VARIABLE RESPONSE

pdp_munv <- variable_response(explainer,
                         variable = "meanUniqueNumericalValues",
                         type="pdp")

pdp_noi <- variable_response(explainer,
                              variable = "number_of_instances",
                              type="pdp")

pdp_mucv <- variable_response(explainer,
                              variable = "meanUniqueCategoricalValues",
                              type="pdp")

pdp_nnf <- variable_response(explainer,
                              variable = "numberOfNumericalFeatures",
                              type="pdp")

pdp_ncf <- variable_response(explainer,
                             variable = "numberOfCategoricalFeatures",
                             type="pdp")


plot(pdp_munv)
plot(pdp_noi)
plot(pdp_mucv)
plot(pdp_nnf)
plot(pdp_ncf)

# PATH PLOT

pp  <- variable_response(explainer,
                         variable =  "model_name",
                         type = "factor")
