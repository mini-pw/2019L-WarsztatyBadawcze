source("functions.R")

dat <- scrap_data()
models_info <- create_models_info(dat[[1]], dat[[2]], dat[[3]])
#filtrowanie porządnych modeli:
models_info <- Filter(function(x) {x$model_name %in% c("regr.svm", "regr.plsr", "regr.gausspr")}, models_info)
models_info <- lapply(models_info, function(x) {
  if(!is.null(x$performance$rsq)) {
    x$performance$r2 <- x$performance$rsq
  }
  x # to niestety było konieczne :(
})

models_df <- create_df_from_info(models_info)
write.csv(models_df, "models_df.csv", row.names = FALSE)


#####Trenowanko

library(dplyr)
library(DALEX)
df <- prepare(models_df, 0)

res <- do_workout(df)
model <- res$model
explainer <- res$explainer
pred <- res$pred
# performance

mlr::calculateROCMeasures(pred)

perf <- model_performance(explainer)
plot(perf)
plot(perf, geom="boxplot")
# variable importance
vi <- variable_importance(explainer, loss_function = loss_root_mean_square)
plot(vi)

pdp  <- variable_response(explainer, variable = "target_skewness", type = "pdp")
plot(pdp)
ale <- variable_response(explainer, variable = "target_skewness", type = "ale")
plot(ale)

pdp  <- variable_response(explainer, variable = "model_param", type = "pdp")
plot(pdp)

library(ggplot2)
ggplot(data = df, aes(x = r2)) + geom_histogram(stat = "count") + facet_wrap(~model_param)

