# wejscie - lista informacji o datasetach
library(purrr)
library(dplyr)
library(jsonlite)

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
  } else if (length(unique(object)) == 2) {
    freq <- as.list(summary.factor(as.factor(object), ...))
    num_minimum <- NA
    num_1qu <- NA
    num_median <- NA
    num_mean <- NA
    num_3qu <- NA
    num_maximum <- NA
  } else {
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
                type = ifelse(isCat || length(unique(object)), "categorical", "numerical"),
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
  write(dataJson, paste0("project/Mateusz_Bakala_Dominik_Rafacz/dataset.json"))
}

create_fake_json <- function() {
  table <- read.csv("project/WarsztatyBadawcze_test.csv", sep=";")
  variables <- table %>% imap(dummary)
  createDataset.internal("fake_datasets", table, "deterred_dataset", "almost_tidyverse", 
                         "fake_source", "http://fake.com", variables)
}

count_factors_gbc <- function(dset, lower, upper = lower) {
  variabs <- dset$preprocessing
  as.integer(
    sum(
      unlist(
        lapply(
          variabs, 
          function(v) ifelse(v$type == "categorical" && 
                        v$number_of_unique_values >=lower &&
                          v$number_of_unique_values <= upper, 1, 0)))))
}




compare_datasets <- function(dataset_info, r_dataset_info) {
  
}

create_fake_json()
r_dataset <- read_json("project/Mateusz_Bakala_Dominik_Rafacz/dataset.json")

#example
dataset <- read_json("models/openml_liver-disorders/dataset.json")
