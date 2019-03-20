library(jsonlite)
library(purrr)
library(reader)
library(digest)
library(mlr)
library(caret)

# MOCNO przekształcony kod funkcji summary.default
# właściwie to napisany od podstaw

set.seed(1)

getFilledMlrCode <- function(name, target, learner, measures, pars, hash, isRegr) {
  return(paste0("#:# libraries
library(digest)
library(mlr)

#:# config
set.seed(1)

#:# data
dataset <- read.csv(\"https://raw.githubusercontent.com/mini-pw/2019L-WarsztatyBadawcze_zbiory/master/toronto_", name, "/", name, ".csv\")
head(dataset)

#:# preprocessing
head(dataset)

#:# model
task = make", ifelse(isRegr, "Regr", "Classif"), "Task(id = \"task\", data = dataset, target = \"", target, "\")
lrn = makeLearner(\"", learner, "\", par.vals = ", deparse(pars), ifelse(isRegr, "", ", predict.type = \"prob\""), ")

#:# hash 
#:# ", hash, "
hash <- digest(list(task, lrn))
hash

#:# audit
cv <- makeResampleDesc(\"CV\", iters = 5)
r <- resample(lrn, task, cv, measures = ", paste0("list(", paste(simplify(sapply(measures, "[", "id")), collapse = ", "), ")"), ")
ACC <- r$aggr
ACC

#:# session info
sink(paste0(\"sessionInfo.txt\"))
sessionInfo()
sink()"
                ))
}

extendedTwoClassSummary <- function (data, lev = NULL, model = NULL) {
  out <- twoClassSummary(data, lev, model)
  out <- c(out, precision(data[, "pred"], data[, "obs"]))
  data[, "pred"] <- factor(data[, "pred"], levels = levels(data[, "obs"]))
  caret:::requireNamespaceQuietStop("e1071")
  out <- c(unlist(e1071::classAgreement(table(data[, "obs"], data[, "pred"])))[c("diag", "kappa")], out)
  out <- c(out, 2*out[5]*out[6]/(out[5] + out[6]))
  names(out) <- c("Accuracy", "Kappa", "AUC", "Recall", "Specificity", "Precision", "F1")
  if (any(is.nan(out))) 
    out[is.nan(out)] <- NA
  out
}

dummary <- function (object, colname, ...) {
  isCat <- is.factor(object) || is.logical(object)
  if(isCat) {
    freq <- as.list(summary.factor(object, ...))
    num_minimum <- NA
    num_1qu <- NA
    num_median <- NA
    num_mean <- NA
    num_3qu <- NA
    num_maximum <- NA
  }
  else {
    freq <- NA
    nas <- is.na(object)
    object <- object[!nas]
    qq <- stats::quantile(object)
    names(qq) <- NULL
    num_minimum <- qq[1]
    num_1qu <- qq[2]
    num_median <- qq[3]
    num_mean <- mean(object)
    num_3qu <- qq[4]
    num_maximum <- qq[5]
  }
  props <- list(name = colname,
                type = ifelse(isCat, "categorical", "numerical"),
                number_of_unique_values = length(unique(object)),
                number_of_missing_values = sum(is.na(object)),
                cat_frequencies = freq,
                num_minimum = num_minimum,
                num_1qu = num_1qu,
                num_median = num_median,
                num_mean = num_mean,
                num_3qu = num_3qu,
                num_maximum = num_maximum)
  return(props)
}

processParams <- function(defaults, hypers) {
  listNames <- names(defaults$pars)
  defaults <- sapply(defaults$pars, "[", "default")
  names(defaults) <- listNames
  params <- modifyList(defaults, hypers)
  return(defaults)
}

getTorontoData <- function(name, saveToCsv = FALSE) {
  download.file(paste0("https://www.cs.toronto.edu/pub/neuron/delve/data/tarfiles/", name, ".tar.gz"), "tmp.tar.gz")
  untar("tmp.tar.gz")
  table <- read.table(paste0("./", name, "/Dataset.data.gz"))
  # nazwy kolumn:
  res <- readLines(paste0("./", name, "/Dataset.spec"))
  res <- res[-c(1:grep("Attributes:", res))]
  writeLines(res, "tmp.txt")
  cols <- read.table("tmp.txt", comment.char = "u")$V2
  file.remove("tmp.txt")
  file.remove("tmp.tar.gz")
  colnames(table) <- make.names(cols, unique = TRUE)
  # here can be inserted dealing with missing data and all that stuff
  if(saveToCsv) {
    write.csv(table, paste0(name, ".csv"), row.names = FALSE)
  }
  return(table)
}

createTorontoDataset <- function(name, added_by) {
  table <- getTorontoData(name)
  
  # część kodu poniżej inspirowana: https://stackoverflow.com/questions/39168484/r-summary-to-parsable-format-preferable-json
  
  variables <- table %>% imap(dummary)
  toDataJson <- list(id = paste0("toronto_", name),
                     added_by = added_by,
                     date = format(Sys.Date(), "%d-%m-%Y"),
                     name = name,
                     source = "cs.toronto.edu",
                     url = paste0("http://www.cs.toronto.edu/~delve/data/", name, "/desc.html"),
                     number_of_features = ncol(table),
                     number_of_instances = nrow(table),
                     number_of_missing_values = sum(is.na(table)),
                     number_of_instances_with_missing_values = sum(apply(table, 1, function(x) any(is.na(x)))),
                     variables = variables)
  dataJson <- list(toDataJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, null = "null")
  dir.create(paste0("toronto_", name))
  write(dataJson, paste0("./toronto_", name, "/dataset.json"))
}

createTask <- function(site, ...) {
  if (site == "toronto") {
    createTorontoTask(...)
  }
}

createTorontoTask <- function(name, local = FALSE, ...) {
  if (local) {
    table <- read.csv(paste0(name, ".csv"))
  }
  else {
    table <- getTorontoData(name)
  }
  createTask.internal("toronto", table, name, ...)
}

createTask.internal <- function(site, table, name, added_by, target, learner, measurer = "mlr", type = "", pars = list()) {
  if (measurer == "mlr" && type == "") {
    isRegr <- ifelse(substr(learner, 1, 4) == "clas", FALSE, TRUE)
    type <- ifelse(isRegr, "regression", "classification")
  }
  else {
    if (type %in% c("regression", "classification")) {
      isRegr <- (type == "regression")
    }
    else {
      stop("Incorrect type. Set regression or classification.")
    }
  }
  
  toTaskJson <- list(id = paste0("toronto_", name),
                     added_by = added_by,
                     date = format(Sys.Date(), "%d-%m-%Y"),
                     dataset_id = name,
                     type = type,
                     target = target)
  taskJson <- list(toTaskJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, null = "null")
  dir.create(paste0("toronto_", name))
  dir.create(paste0("toronto_", name, "/", type, "_", target))
  write(taskJson, paste0("./toronto_", name, "/", type, "_", target, "/task.json"))
  
  if (measurer == "mlr") {
    cv <- makeResampleDesc("CV", iters = 5)
    if (isRegr) {
      mes <- list(mse, rmse, mae, rsq)
    }
    else {
      if (length(unique(table$target)) == 2) {
        mes <- list(acc, auc, tnr, tpr, ppv, f1)
      }
      else {
        mes <- list(acc)
      }
    }
    if (isRegr) {
      task <- makeRegrTask(id = "task", data = table, target = target)
      lrn <- makeLearner(learner, par.vals = pars)
      r <- resample(lrn, task, cv, measures = mes)
    }
    else {
      task <- makeClassifTask(id = "task", data = table, target = target)
      lrn <- makeLearner(learner, par.vals = pars, predict.type = "prob")
      r <- resample(lrn, task, cv, measures = mes)
    }
    results <- r$aggr
    params <- processParams(getParamSet(lrn), getHyperPars(lrn))
    internalName <- lrn$name
    hash <- digest(list(task, lrn))
  }
  else if (measurer == "caret") {
    train_control <- trainControl(method = "cv", number = 5,
                                  summaryFunction = ifelse(length(unique(table$target)) == 2, extendedTwoClassSummary, defaultSummary))
    train_formula <- as.formula(paste0(target, " ~ ."))
    if (is_empty(pars)) {
      cvx <- caret::train(train_formula, data = table, method = learner, trControl = train_control)
      tune <- cvx$bestTune
      params <- cvx$bestTune
      cvx <- caret::train(train_formula, data = table, method = learner, tuneGrid = expand.grid(tune),
                          trControl = train_control)
    }
    else {
      cvx <- caret::train(train_formula, data = table, method = learner, tuneGrid = expand.grid(pars),
                          trControl = train_control)
      params <- pars
    }
    if (isRegr) {
      results <- cvx$results[, c("RMSE", "RMSE", "MAE", "Rsquared")]
      results[, 1] <- results[, 1]^2
    }
    else {
      if (length(unique(table$target)) == 2) {
        results <- cvx$results[, c("Accuracy", "AUC", "Specificity", "Recall", "Precision", "F1")]
      }
      else {
        results <- cvx$results[, "Accuracy"]
      }
    }
    internalName <- cvx$modelInfo$label
    hash <- digest(list(train_formula, table, learner, params))
  }
  
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
                      dataset_id = paste0("toronto_", name),
                      performance = as.list(results))
  auditJson <- list(toAuditJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, na = "null", null = "null")
  dir.create(paste0("toronto_", name, "/", type, "_", target, "/", hash))
  write(auditJson, paste0("toronto_", name, "/", type, "_", target, "/", hash, "/audit.json"))
  
  variables <- table %>% imap(dummary)
  toModelJson <- list(id = hash,
                      added_by = added_by,
                      date = format(Sys.Date(), "%d-%m-%Y"),
                      library = measurer,
                      model_name = internalName,
                      task_id = paste0(type, "_", target),
                      dataset_id = paste0("toronto_", name),
                      parameters = params,
                      preprocessing = variables)
  modelJson <- list(toModelJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, null = "null")
  write(modelJson, paste0("toronto_", name, "/", type, "_", target, "/", hash, "/model.json"))
  
  if (measurer == "mlr") {
    write(getFilledMlrCode(name, target, learner, mes, pars, hash, isRegr),
          paste0("toronto_", name, "/", type, "_", target, "/", hash, "/code.R"))
  }
  # z tym poniżej poczekaj do pojawienia się datasetu na githubie
  # EDIT: jednak nie, jednak należy to robić ręcznie; automatyczne wykonanie kodu dodaje niechciane linie do sessionInfo.txt
  # setwd(paste0("toronto_", name, "/", type, "_", target, "/", hash, "/"))
  # source("code.R", echo = TRUE)
}

#:# PRZYK?ADOWE WYWO?ANIA #:#
# createTorontoDataset("image-seg", "MatiFilozof")
# createTorontoTask("image-seg", "MatiFilozof", "pixel.class", "classif.randomForest", "mlr",
#                   list(mtry = 5, ntree = 450))