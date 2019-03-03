library(jsonlite)
library(purrr)
library(reader)
library(mlr)
library(digest)

# MOCNO przekształcony kod funkcji summary.default
# właściwie to napisany od podstaw

set.seed(1)

getFilledCode <- function(name, target, learner, measures, pars, hash, isRegr) {
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
task = make", ifelse(isRegr, "Regr", "Classif"), "Task(id = \"", name, "\", data = dataset, target = \"", target, "\")
lrn = makeLearner(\"", learner, "\", par.vals = ", deparse(pars), ifelse(isRegr, "", ", predict.type = \"prob\""), ")

#:# hash 
#:# ", hash, "
hash <- digest(lrn)
hash

#:# audit
cv <- makeResampleDesc(\"CV\", iters = 5)
r <- resample(lrn, task, cv, measures = ", paste0("list(", paste(simplify(sapply(measures, "[", "id")), collapse = ", "), ")"), ")
ACC <- r$aggr
ACC

#:# session info
sink(paste0(\"sessionInfo.txt\"))
sessionInfo()
sink()"))
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

createTorontoTask <- function(name, added_by, target, learner, measures = list(acc), measureNames = "ACC", pars = list()) {
  stopifnot(length(measures) == length(measureNames))
  table <- getTorontoData(name)
  type <- ifelse(substr(learner, 1, 4) == "clas", "classification", "regression")
  isRegr <- ifelse(substr(learner, 1, 4) == "clas", FALSE, TRUE)
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
  
  if (type == "classification") {
    class_task <- makeClassifTask(id = paste0("toronto_", name), data = table, target = target)
    class_lrn <- makeLearner(learner, par.vals = pars, predict.type = "prob")
  }
  else {
    class_task <- makeRegrTask(id = paste0("toronto_", name), data = table, target = target)
    class_lrn <- makeLearner(learner, par.vals = pars)
  }
  
  cv <- makeResampleDesc("CV", iters = 5)
  r <- resample(class_lrn, class_task, cv, measures = measures)
  MSE <- r$aggr
  names(MSE) <- measureNames
  
  hash <- digest(learner)
  toAuditJson <- list(id = paste0("audit_", hash),
                      added_by = added_by,
                      date = format(Sys.Date(), "%d-%m-%Y"),
                      model_id = hash,
                      task_id = paste0(type, "_", target),
                      dataset_id = paste0("toronto_", name),
                      performance = as.list(MSE))
  auditJson <- list(toAuditJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, null = "null")
  dir.create(paste0("toronto_", name, "/", type, "_", target, "/", hash))
  write(auditJson, paste0("toronto_", name, "/", type, "_", target, "/", hash, "/audit.json"))
  
  params <- processParams(getParamSet(class_lrn), getHyperPars(class_lrn))
  
  variables <- table %>% imap(dummary)
  toModelJson <- list(id = hash,
                      added_by = added_by,
                      date = format(Sys.Date(), "%d-%m-%Y"),
                      task_id = paste0(type, "_", target),
                      dataset_id = paste0("toronto_", name),
                      parameters = params,
                      preprocessing = variables)
  modelJson <- list(toModelJson) %>% toJSON(auto_unbox = TRUE, pretty = TRUE, null = "null")
  write(modelJson, paste0("toronto_", name, "/", type, "_", target, "/", hash, "/model.json"))
  
  write(getFilledCode(name, target, learner, measures, pars, hash, isRegr),
        paste0("toronto_", name, "/", type, "_", target, "/", hash, "/code.R"))
  # z tym poniżej poczekaj do pojawienia się datasetu na githubie
  # EDIT: jednak nie, jednak należy to robić ręcznie; automatyczne wykonanie kodu dodaje niechciane linie do sessionInfo.txt
  # setwd(paste0("toronto_", name, "/", type, "_", target, "/", hash, "/"))
  # source("code.R", echo = TRUE)
}
