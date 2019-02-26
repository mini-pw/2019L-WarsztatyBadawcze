library(testthat)
library(jsonlite)
library(readr)

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
  new <- data.frame(name = data_info$name,
                    source =  data_info$source,
                    features = data_info$number_of_features,
                    instances = data_info$number_of_instances,
                    missing_values = data_info$number_of_instances_with_missing_values)
  df <- rbind(df, new)
}

readme <- c(
  "# Data Sets",
  "",
  paste("## Number of data sets:", length(dataset_files)),
  "",
  knitr::kable(df)
)
readme

fileConn<-file("models/README.md")
writeLines(readme, fileConn)
close(fileConn)

