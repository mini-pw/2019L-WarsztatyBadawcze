library(dplyr)
library(jsonlite)
library(mlr)
library(stringi)
library(ggplot2)
options(stringsAsFactors = FALSE)

directories <-list.dirs(recursive = TRUE)
directories<-directories[stri_detect_regex(directories,pattern  = "[0-9a-z]{32}$")]
i<-0
classification_model <-list()
classification_audit <-list()
classification_dataset <- list()
classification_task <- list()

for (dir in directories) {
  audit <- read_json(path = file.path(dir,"audit.json"),simplifyVector = TRUE)
  model <- read_json(path = file.path(dir,"model.json"),simplifyVector = TRUE)
  dataset <- read_json(path = file.path(dirname(dirname(dir)),"dataset.json"),simplifyVector = TRUE)
  task <- read_json(path = file.path(dirname(dir),"task.json"),simplifyVector = TRUE)
  if(stri_detect_regex(model$task_id,pattern = "^classification")){
    i<-i+1
    classification_model[i]<-list(model)
    classification_audit[i]<-list(audit)
    classification_dataset[i]<-list(dataset)
    classification_task[i] <- list(task)
  }
}

classification <- tibble(id=character(),added_by=character(),date=character(),library=character(),model_name=character(),task_id=character(),
                         dataset_id=character(), number_of_features=numeric(), number_of_instances=numeric(), frequency1=numeric(), frequency2=numeric(),
                         acc=numeric(),specificity=numeric(),recall=numeric(),precision=numeric(),f1=numeric(), num.trees=numeric(), num.random.splits=numeric())

for(x in 1:i){
  if (classification_model[[x]]$model_name=="classif.ranger") {
  colnames(classification_dataset[[x]]$variables[[classification_task[[x]]$target]]$cat_frequencies) <- c('frequency1', 'frequency2')
  colnames(classification_model[[x]]$parameters$num.trees)
  classification<-rbind(classification,c(classification_model[[x]][1:7],classification_dataset[[x]][7:8], classification_dataset[[x]]$variables[[classification_task[[x]]$target]]$cat_frequencies,
                                         classification_audit[[x]]$performance, classification_model[[x]]$parameters[c(1,17)]))}}

train <-classification[-c(1,2,3,4,5,6)]
train[sapply(train, is.character)] <- lapply(train[sapply(train, is.character)], as.factor)
set.seed(1)
train<-sample_frac(train)

regr_task = makeRegrTask(id = "train", data = train, target = "acc")
regr_lrn = makeLearner("regr.svm")
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
