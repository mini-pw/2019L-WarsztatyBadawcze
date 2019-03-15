source("extendedDataGetter.R")
source("additionalFunctions.R")
source("modelsSettings.R")



generateMultipleModels <- function(username,
                                   modelSettings,
                                   dataset_id = NULL,
                                   target = NULL,
                                   halt_on_errors = FALSE
                                   ) {
  stopifnot(class(modelSettings) == "ModelsSettings")
  
  require(stringi)
  require(jsonlite)
  
  #finding all dirs beggining with "openml_"
  OML_dirs <- stri_match_all_regex(
    list.dirs(recursive = FALSE, full.names = FALSE), "(?<=openml_).+")
  OML_dirs <- unlist(OML_dirs)
  OML_dirs <- OML_dirs[!is.na(OML_dirs)]
  
  if (is.null(dataset_id)) {
    if(length(OML_dirs) >= 2) {
      stop("Error: there's more than one OML directory in this directory\nProvide dataset_id")
    } else if(length(OML_dirs) == 1) {
      if (file.exists(paste0("openml_",dir, .Platform$file.sep, "dataset.json"))) {
        #if there exists exactly one folder "openml_*" and there is "dataset.json", we 
        #find this dataset id
        suppressMessages(
          dataset_id <- getOMLDataSet(data.name = dir)$desc$id  
        )
        message("Automatically found one dataset with id ", dataset_id, ", setting this as dataset_id...")
        } 
    } else {
      stop("Error! Neither OML directory exists nor dataset_id provided")
    }
  } else {
    #if we provided dataset_id, firstly we check if there already is any file "dataset.json" 
    #with this id; otherwise - we create it
    found <- FALSE
    for(dir in OML_dirs) {
      if (file.exists(paste0("openml_",dir, .Platform$file.sep, "dataset.json"))) {
        suppressMessages(
          saved_id <- getOMLDataSet(data.name = dir)$desc$id 
        )
        if(saved_id == dataset_id) {
          found <- TRUE
          message("Found one dataset with id ", dataset_id, "...")
        }
      } 
    }
    if(!found) { 
      message("Didn't find any dataset with id ", dataset_id, ", creating one... \n")
      createDataset("openml", dataset_id, username)
      message("\n Dataset created...")
      
    } 
  }
  
  message("Downloading dataset...")
  #getting dataset
  openMLData <- getOMLDataSet(data.id = dataset_id)
  
  #getting target feature
  #TO DO: generating models for multiple targets
  if (is.null(target)) {
    target <- openMLData$target.features[[1]]
    if(is.null(target)) {
      target <- openMLData$default.target.attribute
    }
    if(is.null(target)) {
      error("Tried to select target automatically, but failed. Provide one manually")
    }
  }
  
  message("Column \"", target, "\" set as target...")
  
  message("\n_________________________________________________________\n" )
  message("Generating models...") 
  
  n <- length(modelSettings$modelsNames)
  t <- as.character(ceiling(log10(n)))
  
  for(i in 1:n) {
    message("")
    message(sprintf(paste0("[%\ ",t,"d/"), i),n,"] >>>>>>>>> BEGGINING")
    message("Model: ")
    cat(modelSettings$modelsNames[i])
    cat("\n")
    message("Parameters: ")
    print(modelSettings$modelsParams[[i]])
    tryCatch(
      createOpenMLTaskWDS(openMLData, 
                          local = FALSE,
                          added_by = username, 
                          target = target, 
                          learner = modelSettings$modelsNames[i],
                          pars = modelSettings$modelsParams[[i]],
                          type = "",
                          measurer = "mlr"),
      error = function(e) {
        warning("Internal error occured while creating model. ")
        message(e)
        if(halt_on_errors) {
          stop("Aborting!")
        } else {
          message("")
          message("FAILED, but we keep our heads up and proceed!")
        }
      }
    )
    
    message(sprintf(paste0("[%\ ",t,"d/"), i),n,"] >>>>>>>>> ENDED")
  }
}


# 
# you should use it when you're in "models" folder;
# if you didn't provide "dataset_id" and there's only one "openml_*" folder, it will use dataset inside this one
# 
# example usage:
#
# generateMultipleModels("DominikRafacz",
#                       MS("classif.ranger", num.trees = c(200, 500, 1000), num.random.splits = 1:5) +
#                       MS("classif.ada", loss = c("exponential", "logistic")) +
#                       MS("classif.binomial", link = c("logit" ,"probit", "cloglog", "cauchit")) +
#                       MS("classif.kknn"),
#                       dataset_id = 40701)
# 
# this code downloads dataset, and generates following models:
# 15 models of type "classif.ranger" with each combination of params num.trees and num.random.splits provided (it uses expand.grid)
#  2 models of type "classif.ada", one with parameter loss ="exponential" and second with loss ="logistic"
#  4 models of type "classsif.binomial" each one with different link parameter
#  1 model  of type "classif.kknn" with default params
#
#
# works only with mlr
# it shouldn't override existing models
# unless you set halt_on_errors on TRUE, it will continue creating models even if errors happen
#
# it should detect target automatically, but you can add string target parameter manually
# 
#