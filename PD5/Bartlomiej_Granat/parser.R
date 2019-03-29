library(jsonlite)
library(mlr)
library("xtable")



#wykorzystuję parser stworzony przez Michała Pastuszkę



#skrypt tworzący dataframe z wynikami i parametrami modeli z repozytorium 

scrape <- function(classifier, #wektor alternatywnych nazw klasyfikatora , np c("RandomForest", "classif.RForest")
                   measures, #nazwy miar, np c("mse", "rmse", "mae", "r2")
                   parameters, #lista parametrów klasyfikatora, w której elementy mogą być wektorami z różnymi nazwami jednego parametru
                   taskType,  #"classification" lub "regression"
                   pathbase = paste0("./models")){ #ścieżka do folderu models
  sep <- .Platform$file.sep
  setDirs <- list.dirs(pathbase, recursive=FALSE)
  measures <- paste0("performance.", measures)
  setPars <- c("id", "number_of_features", "number_of_instances", "number_of_missing_values", "number_of_instances_with_missing_values")
  
  parnames <- character()
  
  for(i in 1:length(parameters)){
    parameters[[i]] <- paste0("parameters.", parameters[[i]])
    parnames <- c(parnames, parameters[[i]][1])
  }
  columns <- c(setPars, measures, parnames)
  df <- data.frame(n=character(), a=integer(), b=integer(), c=integer(), d=integer(), stringsAsFactors=FALSE)
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
    rzero <- setJson[, setPars]
    r <- rzero
    for(task in taskDirs){
      p <- paste0(task, sep, "task.json")
      if(!file.exists(p)){
        warning(paste("file:", p, "does not exist"))
        next
      }
      taskJson <- fromJSON(p)
      if(taskJson$type != taskType) break
      rowname <- taskJson$id
      modelDirs <- list.dirs(task, recursive=FALSE)
      
      for(modelHash in modelDirs){
        r <- rzero
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
        r <- cbind(r, t(pars), model$model_name)
        names(r) <- c(columns, "classifier")
        df <- rbind(df, r)
        rownames(df)[nrow(df)] <-model$id
      }
    }
  }
  return(df)
}


# stworzenie ramek danych z acc(df1) i auc(df2)
df111 <- listLearners()

classifs <- df111$class


out <- scrape(as.vector(classifs[1:40]),
               c("acc","auc"), 
               list(c()), 
               "classification")

df <- out[out$number_of_missing_values==0,]
df$performance.acc <- as.numeric(as.character(df$performance.acc))
df$performance.auc <- as.numeric(as.character(df$performance.auc))
df1 <- na.omit(df[,c(2,3,6,9)])
df2 <- na.omit(df[,c(2,3,7,9)])

# Tasks and learners

regr_task_acc_1 <- makeRegrTask(id = "meta_acc", data = df1, target = "performance.acc")
regr_task_auc_1 <- makeRegrTask(id = "meta_auc", data = df2, target = "performance.auc")
regr_lrn_1 <- makeLearner("regr.rpart", par.vals = list(maxdepth = 5))
regr_lrn_2 <- makeLearner("regr.svm")
regr_lrn_3 <- makeLearner("regr.kknn")
regr_lrn_4 <- makeLearner("regr.gbm")
regr_lrn_5 <- makeLearner("regr.randomForestSRC")

# cross-validation and measures

cv <- makeResampleDesc("CV", iters = 5)
r1_acc <- resample(regr_lrn_1, regr_task_acc_1, cv, measures = list(mse, rmse, mae, rsq))
r2_acc <- resample(regr_lrn_2, regr_task_acc_1, cv, measures = list(mse, rmse, mae, rsq))
r3_acc <- resample(regr_lrn_3, regr_task_acc_1, cv, measures = list(mse, rmse, mae, rsq))
r4_acc <- resample(regr_lrn_4, regr_task_acc_1, cv, measures = list(mse, rmse, mae, rsq))
r5_acc <- resample(regr_lrn_5, regr_task_acc_1, cv, measures = list(mse, rmse, mae, rsq))


r1_auc <- resample(regr_lrn_1, regr_task_auc_1, cv, measures = list(mse, rmse, mae, rsq))
r2_auc <- resample(regr_lrn_2, regr_task_auc_1, cv, measures = list(mse, rmse, mae, rsq))
r3_auc <- resample(regr_lrn_3, regr_task_auc_1, cv, measures = list(mse, rmse, mae, rsq))
r4_auc <- resample(regr_lrn_4, regr_task_auc_1, cv, measures = list(mse, rmse, mae, rsq))
r5_auc <- resample(regr_lrn_5, regr_task_auc_1, cv, measures = list(mse, rmse, mae, rsq))

# scores frames

scores1 <- rbind(r1_acc$aggr, r2_acc$aggr, r3_acc$aggr, r4_acc$aggr,r5_acc$aggr) 
rownames(scores1) <- c("acc_rpart","acc_svm","acc_kknn", "acc_gbm","acc_randomForest")
scores2 <- rbind(r1_auc$aggr, r2_auc$aggr, r3_auc$aggr, r4_auc$aggr, r5_auc$aggr)
rownames(scores2) <- rbind("auc_rpart","auc_svm","auc_kknn","auc_gbm","auc_randomForest") 


