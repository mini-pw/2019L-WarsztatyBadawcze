library(jsonlite)

#skrypt tworzący dataframe z wynikami i parametrami modeli z repozytorium 

scrape <- function(classifier, #wektor alternatywnych nazw klasyfikatora , np c("RandomForest", "classif.RForest")
                   measures, #nazwy miar, np c("mse", "rmse", "mae", "r2")
                   parameters, #lista parametrów klasyfikatora, w której elementy mogą być wektorami z różnymi nazwami jednego parametru
                   taskType,  #"classification" lub "regression"
                   pathbase = paste0("CaseStudies2019S", sep, "models")){ #ścieżka do folderu models
  sep <- .Platform$file.sep
  setDirs <- list.dirs(pathbase, recursive=FALSE)
  measures <- paste0("performance.", measures)
  setPars <- c("id", "number_of_features", "number_of_instances", "number_of_missing_values", "number_of_instances_with_missing_values")
  colPars0 <- c('name', 'type', 'number_of_unique_values', 'number_of_missing_values', 'num_minimum', 'num_1qu', 'num_median', 'num_mean', 'num_3qu', 'num_maximum')
  colPars <- c(colPars0, "ncats")
  colPars <- paste0("target.", colPars)
  parnames <- character()
  
  for(i in 1:length(parameters)){
    parameters[[i]] <- paste0("parameters.", parameters[[i]])
    parnames <- c(parnames, parameters[[i]][1])
  }
  columns <- c(setPars, colPars, measures, parnames)
  df <- data.frame(n=character(), a=integer(), b=integer(), c=integer(), d=integer(),
                   e=character(), f=character(), g=integer(), h=integer(), i=integer(), j=integer(), k=integer(), l=integer(), m=integer(), n=integer(), p=integer(), stringsAsFactors=FALSE)
  for(i in 1:(length(measures)+length(parameters))){
    df <- cbind(df, character())
  }
  colnames(df) <- columns
  
  
  for(dir in setDirs){
    taskDirs <- list.dirs(dir, recursive=FALSE)
    p <- paste0(dir, sep, "dataset.json")
    if(!file.exists(p)){
      warning(paste("file:", p, "does not exist"))
      next
    }
    setJson <- fromJSON(p)
    for(task in taskDirs){
      p <- paste0(task, sep, "task.json")
      if(!file.exists(p)){
        warning(paste("file:", p, "does not exist"))
        next
      }
      taskJson <- fromJSON(p)
      if(taskJson$type != taskType) break
      target <- taskJson$target
      ReZero <- setJson[, setPars]
      print(setJson$id)
      if(length(target) == 0){
        warning(paste("Missing target in", task))
        break
      }
      if(! target %in% colnames(setJson$variables)){
        warning(paste("incorrect target specified in", task))
        break
      }
      if(! all(colPars0 %in% colnames(setJson$variables[, target]))){
        warning(paste("ja jusz nawet nie wiem od czego te ify", task))
        break
      }
      ReZero <- cbind(ReZero, setJson$variables[, target][colPars0])
      if(taskType == "classification"){
        ReZero <- cbind(ReZero, length(colnames(setJson$variables[, target][, "cat_frequencies"])))
      }else if(taskType == "regression"){
        ReZero <- cbind(ReZero, NA)
      }
      rowname <- taskJson$id
      modelDirs <- list.dirs(task, recursive=FALSE)
      
      for(modelHash in modelDirs){
        r <- ReZero
        p <- paste0(modelHash, sep, "model.json")
        if(!file.exists(p)){
          warning(paste("file:", p, "does not exist"))
          next
        }
        model <- fromJSON(p)
        if(!"model_name" %in% colnames(model)){
          warning(paste("missing model_name in", p))
          next
        }
        if(!model$model_name %in% classifier){
          next
        }
        p <- paste0(modelHash, sep, "audit.json")
        if(!file.exists(p)){
          warning(paste("file:", p, "does not exist"))
          next
        }
        audit <- fromJSON(p)
        r <- cbind(r, t(unlist(audit)[measures]))
        ModelParams <- unlist(model)
        pars <- rep(NA, length.out = length(parameters))
        for(i in 1:length(parameters)){
          for(altName in parameters[[i]]){
            val <- ModelParams[altName]
            if(!is.na(val)){
              pars[i] <- val
              break
            }
          }
        }
        r <- cbind(r, t(pars))
        names(r) <- columns
        df <- rbind(df, r)
        rownames(df)[nrow(df)] <- model$id
      }
    }
  }
  return(df)
}

#przykład
out <- scrape("classif.ranger", c("acc", "f1"), list(c("num.trees", "ntree"), c("num.random.splits")), "classification")
