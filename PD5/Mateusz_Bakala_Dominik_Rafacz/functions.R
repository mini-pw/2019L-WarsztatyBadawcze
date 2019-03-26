scrap_data <- function() {
  library(jsonlite)
  
  models_files <- paste0("../../models/",list.files(path = "../../models", pattern = "model\\.json", recursive = TRUE))
  audits_files <- paste0(stringi::stri_extract_last(models_files, regex = ".+(?=model\\.json)"), "audit.json")
  dasets_files <- paste0(stringi::stri_extract_last(models_files, regex = ".+(?=model\\.json)"), "../../dataset.json")
  
  models_lists <- lapply(models_files, function(f) unlist(read_json(f), recursive = FALSE))
  audits_lists <- lapply(audits_files, function(f) unlist(read_json(f), recursive = FALSE))
  dasets_lists <- lapply(dasets_files, function(f) unlist(read_json(f), recursive = FALSE))
  list(models_lists, audits_lists, dasets_lists)
}

create_models_info <- function(models_lists, audits_lists, dasets_lists) {
  models_info <- lapply(1L:length(models_lists), function(i) {
    model <- models_lists[[i]]
    if(startsWith(model$task_id, "regression_")){
      model$performance <- audits_lists[[i]]$performance
      model$num_inst <- dasets_lists[[i]]$number_of_instances
      model
    } else {
      NULL
    }
  })
  models_info <- Filter(Negate(is.null), models_info)
  #tego drugiego mozna naprawic
  models_info<- Filter(Negate(function(x) is.null(x$library)), models_info)
  models_info
}

get_target_name <- function(model) {
  stringi::stri_match_first(model$task_id, regex = "(?<=regression_).*")[1,1]
}
count_bin_facs <- function(model) {
  variabs <- model$preprocessing
  as.integer(sum(unlist(lapply(variabs, function(v) ifelse(v$type == "categorical" && 
                                                             v$number_of_unique_values == 2, 1, 0)))))
}
count_small_facs <- function(model) {
  variabs <- model$preprocessing
  as.integer(sum(unlist(lapply(variabs, function(v) ifelse(v$type == "categorical" && 
                                                             v$number_of_unique_values > 2 &&
                                                             v$number_of_unique_values < 6, 1, 0)))))
}
count_big_facs <- function(model) {
  variabs <- model$preprocessing
  as.integer(sum(unlist(lapply(variabs, function(v) ifelse(v$type == "categorical" && 
                                                             v$number_of_unique_values > 5, 1, 0)))))
}
get_target_iqr <- function(model) {
  tname <- get_target_name(model)
  if(is.na(tname)) {
    return(NA)
  } else {
    ret <- model$preprocessing[[tname]]$num_3qu - model$preprocessing[[tname]]$num_1qu
    if (length(ret) == 0) {
      ret <- NA
    }
    ret
  }
}
get_target_diff <- function(model) {
  tname <- get_target_name(model)
  if(is.na(tname)) {
    return(NA)
  } else {
    ret <- model$preprocessing[[tname]]$num_max - model$preprocessing[[tname]]$num_min
    if (length(ret) == 0) {
      ret <- NA
    }
    ret
  }
}
skew <- function(v) {
  if(!is.null(v$num_3q)) {
    v$num_3qu <- v$num_3q
  }
  if(is.null(v$num_3qu) || is.null(v$num_1qu)) {
    return(NA)
  } else if(is.null(v$num_median) || is.null(v$num_mean)) {
    return(NA)
  } else if(v$num_3qu != v$num_1qu) {
    (v$num_3qu - 2*v$num_median + v$num_1qu) / (v$num_3qu - v$num_1qu)
  } else if (v$num_mean != v$num_median){
    10
  } else {
    0
  }
}
get_target_skewness <- function(model) {
  tname <- get_target_name(model)
  if(is.na(tname)) {
    return(NA)
  } else {
    ret <- skew(model$preprocessing[[tname]])
    if (length(ret) == 0) {
      ret <- NA
    }
    ret
  }
}
count_nonskew_nums <- function(model) {
  vs <- model$preprocessing
  sum(unlist(lapply(1L:length(vs), function(i) ifelse(vs[[i]]$type == "numerical" && 
                                                        names(vs)[i] != get_target_name(model) && 
                                                        length(skew(vs[[i]]) !=0) && 
                                                        abs(skew(vs[[i]])) <= 0.2, 1, 0))))
}
count_small_nums <- function(model) {
  vs <- model$preprocessing
  sum(unlist(lapply(1L:length(vs), function(i) ifelse(vs[[i]]$type == "numerical" && 
                                                        names(vs)[i] != get_target_name(model) && 
                                                        length(skew(vs[[i]]) !=0) && 
                                                        abs(skew(vs[[i]])) <= 0.5 &&
                                                        abs(skew(vs[[i]])) > 0.2, 1, 0))))
}
count_big_nums <- function(model) {
  vs <- model$preprocessing
  sum(unlist(lapply(1L:length(vs), function(i) ifelse(vs[[i]]$type == "numerical" && 
                                                        names(vs)[i] != get_target_name(model) && 
                                                        length(skew(vs[[i]]) !=0) && 
                                                        abs(skew(vs[[i]])) > 0.5, 1, 0))))
}
get_model_param <- function(model) {
  mnam <- model$model_name
  mnam<- paste(mnam, switch (mnam,
                             "regr.gausspr" = model$parameters$kernel,
                             "regr.plsr" = model$parameters$method,
                             "regr.svm" = model$parameters$kernel,
                             NULL))
  mnam
}

create_df_from_info <- function(info) {
  
  id <- unlist(lapply(info, function(x) x$id))
  dset <- unlist(lapply(info, function(x) x$dataset_id))
  lib <- unlist(lapply(info, function(x) x$library))
  mname <- unlist(lapply(info, function(x) x$model_name))
  target <- unlist(lapply(info, get_target_name))
  
  insts <- unlist(lapply(info, function(x) x$num_inst)) # liczba instancji
  columns<- unlist(lapply(info, function(x) length(x$preprocessing))) #liczba kolumn
  
  model_param <- unlist(lapply(info, get_model_param)) #nazwa + parametr
  
  target_iqr <- unlist(lapply(info, get_target_iqr)) #IQR targetu
  target_diff <- unlist(lapply(info, get_target_diff)) #max-min targeti
  target_skewness <- unlist(lapply(info, get_target_skewness)) #kwantylowa skośność (Q3-2Q2+Q1)/(Q3-Q1) targetu
  
  binary_factors <- unlist(lapply(info, count_bin_facs)) # liczba binarnych factorów
  factors3to5 <- unlist(lapply(info, count_small_facs)) # liczba factorów z 3 do 5 klasami
  big_factors <- unlist(lapply(info, count_big_facs)) # liczba dużych factorów
  
  nonskew_numerics <- unlist(lapply(info, count_nonskew_nums)) # liczba nietargetowych kolumn liczbowych z kwantylową skośnością < 0.2
  small_skew_numerics <- unlist(lapply(info, count_small_nums)) # liczba nietargetowych kolumn liczbowych z kwantylową skośnością w [0.2,1)
  big_skew_numerics <- unlist(lapply(info, count_big_nums)) # liczba nietargetowych kolumn liczbowych z kwantylową skośnością >= 1
  
  mse <- unlist(lapply(info, function(x) x$performance$mse))
  rmse <- unlist(lapply(info, function(x) x$performance$rmse))
  mae <- unlist(lapply(info, function(x) x$performance$mae))
  r2 <- unlist(lapply(info, function(x) x$performance$r2))
  
  data.frame(id, dset, lib, mname, target, columns, insts,
             model_param,
             target_iqr, target_diff, target_skewness,
             binary_factors, factors3to5, big_factors,
             nonskew_numerics, small_skew_numerics, big_skew_numerics,
             mse, rmse, mae, r2, metric=rmse/target_diff)
}

prepare <- function(models_df, threshold) {
  models_df %>% filter(!is.na(target_iqr)) %>% 
    select(-id, -dset, -lib, -mname, -target, -metric, -mae, -rmse, -mse)-> costam
  
  costam <- costam %>% filter(model_param %in% c("regr.gausspr polydot", "regr.gausspr rbfdot", "regr.gausspr vanilladot",
                                                 "regr.plsr kernelpls", "regr.plsr oscorespls", "regr.plsr simpls",
                                                 "regr.svm polynomial", "regr.svm radial", "regr.svm sigmoid"))
  
  costam$r2 -> tmp
  costam$r2 <- tmp > threshold
  costam
}

do_workout <- function(df) {
  library(mlr)
  library(DALEX)
  tsk <- makeClassifTask("id", data = df, target = "r2")
  lrn <- makeLearner("classif.ranger", predict.type = "prob")
  set.seed(1)
  
  train_index <- sample(1:nrow(df), 0.7 * nrow(df))
  test_index <- setdiff(1:nrow(df), train_index)
  test_df <- df[test_index,]
  
  classif <- train(lrn, tsk, subset=train_index)
  
  print(calculateConfusionMatrix(predict(classif, newdata = test_df)))
  
  custom_predict_classif <- function(object, newdata) {
    pred <- predict(object, newdata=newdata)
    response <- pred$data[,3]
    return(response)
  }
  
  list(model = classif,
    explainer = explain(classif, data=test_df, y=test_df$r2, label= "ranger", predict_function = custom_predict_classif))
}
