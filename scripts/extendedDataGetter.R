library("jsonlite")
library("purrr")
library("reader")
library("digest")
library("R.utils")

set.seed(1)

getLinkToFile <- function(site, name) {
  if (tolower(site) == "toronto") {
    return(paste0("read.csv(\"https://raw.githubusercontent.com/mini-pw/2019L-WarsztatyBadawcze_zbiory/master/", site, "_", name, "/", name, ".csv\")"))
  }
  if (tolower(site) == "openml") {
    return(paste0("getOMLDataSet(data.name = \"", name, "\")"))
  }
}

getFilledModelCode <- function(measurer, target, learner, parsText, isRegr) {
  if (measurer == "mlr") {
    return(paste0("task = make", ifelse(isRegr, "Regr", "Classif"), "Task(id = \"task\", data = dataset$data, target = \"", target, "\")\n",
                  "lrn = makeLearner(\"", learner, "\", par.vals = ", parsText, ifelse(isRegr, "", ", predict.type = \"prob\""), ")"))
  }
  if (measurer == "caret") {
    return(paste0("train_control <- trainControl(method = \"cv\", number = 5)\n",
                  "cvx <- train(", target, " ~ ., data = dataset$data, method = \"", learner, "\", tuneGrid = ", parsText, ", trControl = train_control)"))
  }
}

getFilledHashCode <- function(measurer, target, learner, parsText) {
  if (measurer == "mlr") {
    return(paste0("task, lrn"))
  }
  if (measurer == "caret") {
    return(paste0(target, " ~ ., dataset, \"", learner, "\", ", parsText))
  }
}

getFilledAuditCode <- function(measurer, measures) {
  if (measurer == "mlr") {
    return(paste0("cv <- makeResampleDesc(\"CV\", iters = 5)\n",
                  "r <- mlr::resample(lrn, task, cv, measures = ", paste0("list(", paste(simplify(sapply(measures, "[", "id")), collapse = ", "), ")"), ")\n",
                  "ACC <- r$aggr\n",
                  "ACC"))
  }
  if (measurer == "caret") {
    return(paste0("cvx$results"))
  }
}

getFilledCode <- function(site, name, target, learner, measures, measurer, parsText, hash, isRegr) {
  require(R.utils)
  return(paste0(
"#:# libraries\nlibrary(digest)\nlibrary(mlr)",
ifelse(tolower(site) == "openml", "\nlibrary(OpenML)\nlibrary(farff)", ""), "\n\n",
"#:# config\nset.seed(1)\n\n",
"#:# data\ndataset <- ", doCall(getLinkToFile, site = site, name = name), "\nhead(dataset$data)\n\n",
"#:# preprocessing\nhead(dataset$data)\n\n",
"#:# model\n", doCall(getFilledModelCode, measurer = measurer, target = target, learner = learner, parsText = parsText, isRegr = isRegr), "\n\n",
"#:# hash\n#:# ", hash, "\nhash <- digest(list(", doCall(getFilledHashCode, measurer = measurer, target = target, learner = learner, parsText = parsText), "))\nhash\n\n",
"#:# audit\n", doCall(getFilledAuditCode, measurer = measurer, measures = measures), "\n\n",
"#:# session info\nsink(paste0(\"sessionInfo.txt\"))\nsessionInfo()\nsink()"
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
  return(params)
}

getTorontoData <- function(name, saveToCsv = FALSE) {
  download.file(paste0("https://www.cs.toronto.edu/pub/neuron/delve/data/tarfiles/", name, ".tar.gz"), "tmp.tar.gz")
  untar("tmp.tar.gz")
  tryCatch({
    table <- read.table(paste0("./", name, "/Dataset.data.gz"))
    # nazwy kolumn:
    res <- readLines(paste0("./", name, "/Dataset.spec"))
    res <- res[-c(1:grep("Attributes:", res))]
    writeLines(res, "tmp.txt")
    cols <- read.table("tmp.txt", comment.char = "u")$V2
    colnames(table) <- make.names(cols, unique = TRUE)
  }, finally = {
    # czyszczenie pomocniczych plików
    file.remove("tmp.tar.gz")
    file.remove("tmp.txt")
    removeDirectory(name, recursive = TRUE)
  })
  # końcowe poprawki
  # here can be inserted dealing with missing data and all that stuff
  if(saveToCsv) {
    write.csv(table, paste0(name, ".csv"), row.names = FALSE)
  }
  return(table)
}

getTorontoDataSet <- function(name) {
  #creating DataSet object
  dataSet <- DataSet(getTorontoData(name), name)
  return(dataSet)
}

createDataset.internal <- function(site, table, name, added_by, source, url, variables) {
  toDataJson <- list(id = paste0(site, "_", name),
                     added_by = added_by,
                     date = format(Sys.Date(), "%d-%m-%Y"),
                     name = name,
                     source = source,
                     url = url,
                     number_of_features = ncol(table),
                     number_of_instances = nrow(table),
                     number_of_missing_values = sum(is.na(table)),
                     number_of_instances_with_missing_values = sum(apply(table, 1, function(x) any(is.na(x)))),
                     variables = variables)
  dataJson <- list(toDataJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, null = "null")
  dir.create(paste0(site, "_", name))
  write(dataJson, paste0(site, "_", name, "/dataset.json"))
}

createTask.internal <- function(site, table, name, added_by, target, learner, measurer, type, pars) {
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
  
  toTaskJson <- list(id = paste0(site, "_", name),
                     added_by = added_by,
                     date = format(Sys.Date(), "%d-%m-%Y"),
                     dataset_id = name,
                     type = type,
                     target = target)
  taskJson <- list(toTaskJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, null = "null")
  dir.create(paste0(site, "_", name))
  dir.create(paste0(site, "_", name, "/", type, "_", target))
  write(taskJson, paste0("./", site, "_", name, "/", type, "_", target, "/task.json"))
  
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
    
    r <- mlr::resample(lrn, task, cv, measures = mes)
    results <- r$aggr
    params <- processParams(getParamSet(lrn), getHyperPars(lrn))
    internalName <- learner
    hash <- digest(list(task, lrn))
  }
  else if (measurer == "caret") {
    library("caret")
    set.seed(1)
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
                      dataset_id = paste0(site, "_", name),
                      performance = as.list(results))
  auditJson <- list(toAuditJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, na = "null", null = "null")
  dir.create(paste0(site, "_", name, "/", type, "_", target, "/", hash))
  write(auditJson, paste0(site, "_", name, "/", type, "_", target, "/", hash, "/audit.json"))
  
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
  write(modelJson, paste0(site, "_", name, "/", type, "_", target, "/", hash, "/model.json"))
  
  if (measurer == "mlr") {
    parsText <- deparse(pars)
  }
  else if (measurer == "caret") {
    parsText <- paste0("expand.grid(", deparse(pars), ")")
  }
  write(getFilledCode(site, name, target, learner, mes, measurer, parsText, hash, isRegr),
        paste0(site, "_", name, "/", type, "_", target, "/", hash, "/code.R"))
  sink(paste0(site, "_", name, "/", type, "_", target, "/", hash, "/sessionInfo.txt"))
  print(sessionInfo())
  sink()
}

createTorontoDataset <- function(name, added_by) {
  tmozable <- getTorontoData(name)
  source <- "cs.toronto.edu"
  url <- paste0("http://www.cs.toronto.edu/~delve/data/", name, "/desc.html")
  variables <- table %>% imap(dummary)
  createDataset.internal("toronto", table, name, added_by, source, url, variables)
}

createOpenMLDataset <- function(name, added_by) {
  library("OpenML")
  library("farff")
  if (is.numeric(name)) {
    openMLData <- getOMLDataSet(data.id = name)
  }
  else {
    openMLData <- getOMLDataSet(data.name = name)
  }
  table <- openMLData$data
  name <- openMLData$desc$name
  source <- "openml"
  url <- openMLData$desc$url
  variables <- table %>% imap(dummary)
  createDataset.internal("openml", table, name, added_by, source, url, variables)
}

createTorontoTask <- function(name, local, added_by, target, learner, measurer, type, pars) {
  if (local) {
    table <- read.csv(paste0(name, ".csv"))
  }
  else {
    table <- getTorontoData(name)
  }
  createTask.internal("toronto", table, name, added_by, target, learner, measurer, type, pars)
}

createOpenMLTask <- function(name, local, added_by, target, learner, measurer, type, pars) {
  library("OpenML")
  library("farff")
  if (local == TRUE) {
    stop("This one hasn't been implemented yet.")
  }
  if (is.numeric(name)) {
    openMLData <- getOMLDataSet(data.id = name)
  }
  else {
    openMLData <- getOMLDataSet(data.name = name)
  }
  table <- na.omit(openMLData$data)
  name <- openMLData$desc$name
  createTask.internal("openml", table, name, added_by, target, learner, measurer, type, pars)
}

createDataset <- function(site, name, added_by) {
  if (tolower(site) == "toronto") {
    createTorontoDataset(name, added_by)
  }
  else if (tolower(site) == "openml") {
    createOpenMLDataset(name, added_by)
  }
}

createTask <- function(site, name, local = FALSE, added_by, target, learner, measurer = "mlr", type = "", pars = list()) {
  if (tolower(site) == "toronto") {
    createTorontoTask(name, local, added_by, target, learner, measurer = "mlr", type = type, pars = list())
  }
  else if (tolower(site) == "openml") {
    createOpenMLTask(name, local, added_by, target, learner, measurer = "mlr", type = type, pars = list())
  }
}

createBoth <- function(site, name, local = FALSE, added_by, target, learner, measurer = "mlr", type = "", pars = list()) {
  createDataset(site, name, added_by)
  createTask(site, name, local, added_by, target, learner, measurer, type, pars)
}

#:# PRZYK?ADOWE WYWO?ANIA #:#
# createDataset("toronto", "image-seg", "MatiFilozof")
# createTask("toronto", "image-seg", FALSE, "RandomGithubUser", "pixel.class", "classif.randomForest", "mlr",
#                   list(mtry = 5, ntree = 450))

#:# OBSŁUGA #:#
# Wszystkie funkcje poza createTask() i createDataset() są wewnętrzne i nie zaleca się ich bezpośredniego wywoływania.
# A tak to argumentami są głównie stringi, chyba że wskazane inaczej.
# Sugeruje się naśladować przykładowe wywołania.