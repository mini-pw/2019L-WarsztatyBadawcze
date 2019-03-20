source("extendedDataGetter.R")
source("dataSet.R")

getDataSet <- function(site, dataset_id) {
  if (site == "openml") {
    siteData <- getOMLDataSet(data.id = dataset_id)
    siteData <- as.DataSet(siteData)
  } else if (site == "toronto") {
    siteData <- getTorontoDataSet(name = dataset_id)
  } else {
    error("This function doesn't support using this site. Please implement it and commit to Github")
  }
  return(siteData)
}

createTaskWDS <- function(site, dataSet, local, added_by, learner, measurer, type, pars) {
  if (local == TRUE) {
    stop("This one hasn't been implemented yet.")
  }
  createTaskWDS.internal(site, dataSet$data, dataSet$name, added_by, dataSet$target, learner, measurer, type, pars)
}

createTaskWDS.internal <- function(site, table, name, added_by, target, learner, measurer, type, pars) {
  if (measurer == "mlr" && type == "") {
    isRegr <- ifelse(substr(learner, 1, 4) == "clas", FALSE, TRUE)
    type <- ifelse(isRegr, "regression", "classification")
  }
  else {
    if (type %in% c("regression", "classification")) {
      isRegr <- (type == "regression")
    }
    else {
      stop("Incorrect type. Set \"regression\" or \"classification\".")
    }
  }
  
  sep <- .Platform$file.sep
  
  if(!dir.exists(paste0(site, "_", name, sep, type, "_", target))) {
    dir.create(paste0(site, "_", name, sep, type, "_", target))
  }
  if(!file.exists(paste0(site, "_", name, sep, type, "_", target, sep, "task.json"))){
    toTaskJson <- list(id = paste0(site, "_", name),
                       added_by = added_by,
                       date = format(Sys.Date(), "%d-%m-%Y"),
                       dataset_id = name,
                       type = type,
                       target = target)
    taskJson <- list(toTaskJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, null = "null")
    
    write(taskJson, paste0(site, "_", name, sep, type, "_", target, sep, "task.json"))
  }
  
  
  
  if (measurer == "mlr") {
    library("mlr")
    
    set.seed(1)
    if (isRegr) {
      task <- makeRegrTask(id = "task", data = table, target = target)
      lrn <- makeLearner(learner, par.vals = pars)
    }
    else {
      task <- makeClassifTask(id = "task", data = table, target = target)
      lrn <- makeLearner(learner, par.vals = pars, predict.type = "prob")
    }
    hash <- digest(list(task, lrn))
    message("Learner and task hashed: ", hash)
    
    cv <- makeResampleDesc("CV", iters = 5)
    if (isRegr) {
      mes <- list(mse, rmse, mae, rsq)
    }
    else {
      if (length(unique(table[[target]])) == 2) {
        mes <- list(acc, auc, tnr, tpr, ppv, f1)
      }
      else {
        mes <- list(acc)
      }
    }
    
    someone_was_faster <- FALSE
    if(dir.exists(paste0(site, "_", name, sep, type, "_", target, sep, hash))) {
      if(length(list.files(paste0(site, "_", name, sep, type, "_", target, sep, hash))) == 0) {
        message("Directory with this hash name exists, but is empty. Proceeding...")
      } else {
        message("Model with this hash already exists! Returning... ")
        someone_was_faster <- TRUE
      }
    } else {
      r <- mlr::resample(lrn, task, cv, measures = mes)
      results <- r$aggr
      params <- processParams(getParamSet(lrn), getHyperPars(lrn))
      internalName <- learner
    }
  }
  else if (measurer == "caret") {
    error("You abused your power. You shouldn't be here!")
  }
    ### 
    ### shouldn't happen by accident as this function is called only with measurer param set to mlr
    ### this code is just copy of original function, therefore is commented out
    ###
    
  #   library("caret")
  #   train_control <- trainControl(method = "cv", number = 5,
  #                                 summaryFunction = ifelse(length(unique(table$target)) == 2, extendedTwoClassSummary, defaultSummary))
  #   train_formula <- as.formula(paste0(target, " ~ ."))
  #   if (is_empty(pars)) {
  #     cvx <- caret::train(train_formula, data = table, method = learner, trControl = train_control)
  #     tune <- cvx$bestTune
  #     params <- cvx$bestTune
  #     cvx <- caret::train(train_formula, data = table, method = learner, tuneGrid = expand.grid(tune),
  #                         trControl = train_control)
  #   }
  #   else {
  #     cvx <- caret::train(train_formula, data = table, method = learner, tuneGrid = expand.grid(pars),
  #                         trControl = train_control)
  #     params <- pars
  #   }
  #   if (isRegr) {
  #     results <- cvx$results[, c("RMSE", "RMSE", "MAE", "Rsquared")]
  #     results[, 1] <- results[, 1]^2
  #   }
  #   else {
  #     if (length(unique(table$target)) == 2) {
  #       results <- cvx$results[, c("Accuracy", "AUC", "Specificity", "Recall", "Precision", "F1")]
  #     }
  #     else {
  #       results <- cvx$results[, "Accuracy"]
  #     }
  #   }
  #   internalName <- cvx$modelInfo$label
  #   hash <- digest(list(train_formula, table, learner, params))
  # }
  
  if(!someone_was_faster) {
    params <- as.list(params)
    
    if (isRegr) {
      length(results) <- 4
      names(results) <- c("mse", "rmse", "mae", "r2")
    }
    else {
      length(results) <- 6
      names(results) <- c("acc", "auc", "specificity", "recall", "precision", "f1")
    }
    
    toAuditJson <- list(id = paste0("audit_", hash),
                        date = format(Sys.Date(), "%d-%m-%Y"),
                        added_by = added_by,
                        model_id = hash,
                        task_id = paste0(type, "_", target),
                        dataset_id = paste0(site, "_", name),
                        performance = as.list(results))
    auditJson <- list(toAuditJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, na = "null", null = "null")
    
    if(!dir.exists(paste0(site, "_", name, sep, type, "_", target, sep, hash))){
      dir.create(paste0(site, "_", name, sep, type, "_", target, sep, hash))
    }
    write(auditJson, paste0(site, "_", name, sep, type, "_", target, sep, hash, sep, "audit.json"))
    
    variables <- table %>% imap(dummary)
    toModelJson <- list(id = hash,
                        added_by = added_by,
                        date = format(Sys.Date(), "%d-%m-%Y"),
                        library = measurer,
                        model_name = internalName,
                        task_id = paste0(type, "_", target),
                        dataset_id = paste0(site, "_", name),
                        parameters = params,
                        preprocessing = variables)
    modelJson <- list(toModelJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, null = "null")
    write(modelJson, paste0(site, "_", name, sep, type, "_", target, sep, hash, sep, "model.json"))
    
    if (measurer == "mlr") {
      parsText <- deparse(pars)
    }
    else if (measurer == "caret") {
      parsText <- paste0("expand.grid(", deparse(pars), ")")
    }
    write(getFilledCode(site, name, target, learner, mes, measurer, parsText, hash, isRegr),
          paste0(site, "_", name, sep, type, "_", target, sep, hash, sep, "code.R"))
    sink(paste0(site, "_", name, sep, type, "_", target, sep, hash, sep, "sessionInfo.txt"))
    print(sessionInfo())
    sink()
  }
  
}