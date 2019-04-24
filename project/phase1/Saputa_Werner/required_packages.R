pckgs_ <- unique(c("parallelMap", "readr", "digest", "mboost", "e1071", "gbm", "klaR", "mda", "ada", "rpart", "ranger", "mboost", "party", "kknn", "C50", "earth", "randomForest", "adabag", "xgboost", "penalized", "neuralnet", "nnet", "glmnet", "RWeka", "rotationForest", "MASS", "caret", "pls", "RRF", "randomForestSRC", "h2o", "nodeHarvest", "kernlab", "bartMachine", "dplyr", "mlr"))

check_required_packages <- function(pckgs = pckgs_){
  for(i in pckgs){
    tryCatch(
      {
        library(i, character.only = TRUE)
        #detach(paste0("package:", i), unload=TRUE)
      }, 
      error = function(e){
        warning(paste0("installing package ", i))
        message(e)
        install.packages(i, dependencies = TRUE)
      }
    )
  }  
}
