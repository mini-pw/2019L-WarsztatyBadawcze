source("extendedDataGetter.R")
source("additionalFunctions.R")
source("modelsSettings.R")
setwd(paste0("..", .Platform$file.sep, "models"))


generateMultipleModels <- function(username,
                                   modelSettings,
                                   dataset_id = NULL,
                                   target = NULL,
                                   site = "openml",
                                   halt_on_errors = FALSE,
                                   auto_search = FALSE
                                   ) {
  stopifnot(class(modelSettings) == "ModelsSettings")
  
  require(stringi)
  require(jsonlite)
  require(OpenML)
  require(dplyr)
  require(purrr)
  require(digest)
  require(R.utils)
  
  site <- tolower(site)
  # if (is.null(target) && site != "openml") {
  #   stop("Please provide target name! Only OpenML supports finding it automatically")
  # }
  
  if(auto_search){
    #finding all dirs beggining with "<site>_", usually "openml_"
    site_dirs <- stri_match_all_regex(
      list.dirs(recursive = FALSE, full.names = FALSE), paste0("(?<=", site, "_).+"))
    site_dirs <- unlist(site_dirs)
    site_dirs <- site_dirs[!is.na(site_dirs)]
    
    if (is.null(dataset_id)) {
      if(length(site_dirs) >= 2) {
        dataset_id <- stop("There's more than one directory of this site in this directory\nProvide dataset_id")
      } else if (length(site_dirs) == 1) {
        if (file.exists(paste0(site, "_", site_dirs, .Platform$file.sep, "dataset.json"))) {
          #if there exists exactly one folder "<site>_*" and there is "dataset.json", we
          #find this dataset id
          suppressMessages(
            if (site == "openml") {
              dataset_id <- getOMLDataSet(data.name = site_dirs)$desc$id
            } else {
              dataset_id <- site_dirs
            }
          )
          message("Automatically found one dataset with id ", dataset_id, ", setting this as dataset_id...")
        } 
      } else {
        stop("Neither directory of this site exists nor dataset_id provided")
      }
    } else {
      #if we provided dataset_id, firstly we check if there already is any file "dataset.json" 
      #with this id; otherwise - we create it
      found <- FALSE
      for (dir in site_dirs) {
        if (file.exists(paste0(site, "_", dir, .Platform$file.sep, "dataset.json"))) {
          if (site == "openml") {
            suppressMessages(
              saved_id <- getOMLDataSet(data.name = dir)$desc$id 
            )
            if(saved_id == dataset_id) {
              found <- TRUE
              message("Found one dataset with id ", dataset_id, "...")
            }
          } else {
            found <- TRUE
            message("Found one dataset with id ", dataset_id, "...")
          }
        } 
      }
      if (!found) { 
        message("Didn't find any dataset with id ", dataset_id, ", creating one... \n")
        createDataset(site, dataset_id, username)
        message("\nDataset created...")
      }
    }
    
    message("Downloading dataset...")
    #getting dataset
    suppressMessages(
      siteData <- getDataSet(site, dataset_id)
    )
  } else {
    message("Downloading dataset...")
    #getting dataset
    suppressMessages(
      siteData <- getDataSet(site, dataset_id)
    )
    if (file.exists(paste0(site, "_", siteData$name, .Platform$file.sep, "dataset.json"))) {
      message("Dataset already exists...")
    } else { 
      message("Didn't find any dataset with id ", dataset_id, ", creating one... \n")
      createDataset(site, dataset_id, username)
      message("\nDataset created...")
    } 
  }
  
  #getting target feature
  #TO DO: generating models for multiple targets
  if (is.null(target)) {
    target <- siteData$target[1]
    if(is.null(target)) {
      show(siteData)
      target <- readline(
        prompt = "Tried to select target automatically, but failed. Provide one manually (with plain text, please): ")
    }
  }
  
  message("Column \"", target, "\" set as target...")
  siteData$target <- target
  
  message("\n_________________________________________________________\n" )
  message("Generating models...") 
  
  n <- length(modelSettings$modelsNames)
  t <- as.character(ceiling(log10(n)))
  
  for(i in 1:n) {
    message("")
    message(sprintf(paste0("[%\ ", t, "d/"), i), n, "] >>>>>>>>> BEGINNING")
    message("Model: ")
    cat(modelSettings$modelsNames[i])
    cat("\n")
    message("Parameters: ")
    t2 <- unlist(modelSettings$modelsParams[[i]])
    cat(paste(names(t2), "=", t2, collapse = "\n"))
    cat("\n")
    tryCatch(
      createTaskWDS(site = site,
                    siteData,
                    local = FALSE,
                    added_by = username,
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
    
    message(sprintf(paste0("[%\ ", t, "d/"), i), n, "] >>>>>>>>> ENDED")
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