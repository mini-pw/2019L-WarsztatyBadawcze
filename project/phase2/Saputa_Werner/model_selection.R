require(mlr)
pretrained_filename <- "pretrained_AUC.rda"
models_filename <- "compatible_models_mlr.rds"

model_AUC <- readRDS(pretrained_filename)
compatible_models <- unlist(readRDS(models_filename))


black_box <- function(dataset, model_list = compatible_models, stat_fun = cr_stats, pred_model = model_AUC){
  # return a list of mlr learners with their might-be AUC score
    stats <- stat_fun(dataset)
    rows <- data.frame("library" = "mlr",
                      "model_name" = compatible_models,
                      "numberOfCategoricalFeatures" = stats[1],
                      "numberOfNumericalFeatures" = stats[2],
                      "meanUniqueNumericalValues" = stats[3],
                      "meanUniqueCategoricalValues" = stats[4],
                      "meanNumberMissing" = stats[5],
                      "number_of_instances" = stats[6])
    
    pred <- predict(model_AUC, newdata = rows)
    rt <- data.frame("model" = model_list, "score" = pred$data[[1]])
    rownames(rt) <- NULL
    rt
}
