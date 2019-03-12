library(testthat)
library(jsonlite)
library(readr)
library(dplyr)

path <- getwd()

json_files <- list.files(pattern = "dataset.json$", recursive = TRUE)
dataset_files <- json_files[grepl("^models/", json_files)]

df <- data.frame(name = character(),
           source = character(),
           features = numeric(),
           instances = numeric(),
           missing_values = numeric()
           )

for(file in dataset_files){
  data_info <- fromJSON(file)
  print(file)
  
  task_path <- gsub(pattern = "/dataset.json", "", file)
  setwd(paste(path, task_path, sep = "/"))
  
  task_files <- list.files(pattern = "", recursive = FALSE)
  tasks <- task_files[grepl("^(classification|regression)", task_files)]

  num_of_models <- 0
    
  if(length(tasks) > 0){
    tasks_paths <- paste(task_path, tasks, sep="/")
    for(tsk in tasks_paths){
      setwd(paste(path, tsk, sep = "/"))
      model_files <- list.files(pattern = "", recursive = FALSE)
      model_files <- model_files[!(model_files %in% c("README.md", "task.json"))]
      num_of_models <- num_of_models + length(model_files)
    }
  
  }
  
  new <- data.frame(name = data_info$name,
                    source =  data_info$source,
                    features = data_info$number_of_features,
                    instances = data_info$number_of_instances,
                    missing_val = data_info$number_of_instances_with_missing_values,
                    tasks = length(tasks),
                    models = num_of_models)
  df <- rbind(df, new)
  setwd(path)
}

readme <- c(
  "# Data Sets",
  "",
  paste("## Number of data sets:", length(dataset_files)),
  "",
  paste("## Number of tasks:", sum(df$tasks)),
  "",
  paste("## Number of models:", sum(df$models)),
  "",
  knitr::kable(df)
)
readme
setwd(path)

fileConn<-file("models/README.md")
writeLines(readme, fileConn)
close(fileConn)

