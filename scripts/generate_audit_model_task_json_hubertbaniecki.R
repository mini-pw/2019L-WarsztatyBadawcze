#:#  dodać ten plik do folderu i w konsoli lub pliku odpalić:  #:#
# source("generate_audit_model_task_json_hubertbaniecki.R"); make3JSON()
#:##############################################################:#

library(jsonlite)
library(mlr)

make3JSON <- function() {

  # DATASET BEZ MISSING VALUES, pustych, "?", Unknown itp.
  # ewentualnie, jeżeli wiemy, że  missing to NA
  #dane <- na.omit(df)
  
  dane <- df
  
  # nazwy zmiennych muszą się zgadzać z tymi w code.R , ew. zmienić names(measures)
  # df - hash - classif_task - classif_lrn - r$aggr 
  
  added_by <- "hubertbaniecki"
  dataset_id <- "openml_irish"                      # "kaggle_barcelona-data-sets-accidents-2017"
  modelType <- "classification"                     # "regression" 
  
  nhash <- hash
  pasteHash <- paste("audit_", hash, sep="")
  id <- classif_task$task.desc$target               # regr_task 
  target <- classif_task$task.desc$target           # regr_task
  parameters <- lapply(getLearnerParamSet(classif_lrn)$pars, function(x){ ifelse(is.null(x$default), NA, x$default)}) #regr_lrn
  task_id <- paste(modelType, "_", id, sep = "")
  
  measures <- as.list(r$aggr)                     
  names(measures) <- c("ACC", "AUC") 
  #names(measures) <- c("MSE") 
  
  # tworzy folder z nazwą hash i task_id
  dir.create(hash)
  dir.create(task_id)
  
  #########################################################################################################
  
  variablesList <- list()
  
  for(i in 1:dim(dane)[2]){
    variableName <- colnames(dane)[i]
    column <- dane[,i]
    
    if(is.numeric(column)){ 
      variablesList[[variableName]] <- numericalColumnToList(as.numeric(as.character(column)), variableName)
    } else {
      variablesList[[variableName]] <- categoricalColumnToList(as.character(column), variableName)
    }
  }
  
  auditJson <- list(
    "id" = pasteHash,
    "date" =  format(Sys.Date(), format="%d-%m-%Y"),
    "added_by" =  added_by,
    "model_id" =  nhash,
    "task_id" =  task_id,
    "dataset_id" = dataset_id,
    "performance" = measures
  )
  modelJson <- list(
    "id" = nhash,
    "added_by" = added_by,
    "date" = format(Sys.Date(), format="%d-%m-%Y"),
    "task_id" =  task_id,
    "dataset_id" =  dataset_id,
    "parameters" =  parameters,
    "preprocessing" = variablesList
  )
  taskJson <- list(
    "id" =  task_id,
    "added_by" =  added_by,
    "date" =  format(Sys.Date(), format="%d-%m-%Y"),
    "dataset_id" = dataset_id,
    "type" = modelType,
    "target" = target
  )
  
  temp <- jsonlite::toJSON(list(modelJson), pretty = TRUE, auto_unbox = TRUE, .na = "null")
  write(temp, "model.json")
  
  temp2 <- jsonlite::toJSON(list(auditJson), pretty = TRUE, auto_unbox = TRUE, .na = "null")
  write(temp2, "audit.json")
  
  temp3 <- jsonlite::toJSON(list(taskJson), pretty = TRUE, auto_unbox = TRUE, .na = "null")
  write(temp3, "task.json")
}

categoricalColumnToList <- function(column, name) {
  freq <- table(column)
  catFrequenciesList <- as.list(as.integer(freq))
  names(catFrequenciesList) <- names(freq)
  
  ret <- list("name" = name,
              "type" = "categorical",
              "number_of_unique_values" = length(unique(rownames(table(column)))),
              "number_of_missing_values" = sum(is.na(column)),
              "cat_frequencies" = catFrequenciesList,
              "num_minimum" = NA,
              "num_1qu" = NA,
              "num_median" = NA,
              "num_mean" = NA,
              "num_3qu" = NA,
              "num_maximum" = NA)
  ret
}

numericalColumnToList <- function(column, name) {
  quantiles <- quantile(column, na.rm=TRUE)
  
  ret <- list("name" = name,
              "type" = "numerical",
              "number_of_unique_values" = length(unique(rownames(table(column)))),
              "number_of_missing_values" = sum(is.na(column)),
              "cat_frequencies" = NA,
              "num_minimum" = quantiles[[1]],
              "num_1qu" = quantiles[[2]],
              "num_median" = quantiles[[3]],
              "num_mean" = mean(column, na.rm=TRUE),
              "num_3qu" = quantiles[[4]],
              "num_maximum" = quantiles[[5]])
  ret
}