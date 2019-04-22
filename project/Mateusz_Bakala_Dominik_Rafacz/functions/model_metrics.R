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
  write(dataJson, paste0("dataset.json"))
}

create_fake_json <- function(deferred_dataset) {
  variables <- deferred_dataset %>% imap(dummary)
  createDataset.internal("fake_datasets", deferred_dataset, "deterred_dataset", "almost_tidyverse", 
                         "fake_source", "http://fake.com", variables)
}

count_factors_all <- function(dset) {
  variabs <- dset$variables
  as.integer(sum(unlist(lapply(variabs, 
                               function(v) ifelse(v$type == "categorical", 1, 0)))))
}

count_factors_gbc <- function(dset, lower, upper = lower) {
  variabs <- dset$variables
  as.integer(sum(unlist(lapply(variabs, 
          function(v) ifelse(v$type == "categorical" && 
                        v$number_of_unique_values >=lower &&
                          v$number_of_unique_values <= upper, 1, 0)))))
}

count_factors_range <- function(dset) {
  c(count_factors_gbc(dset, 2),
    count_factors_gbc(dset, 3, 4),
    count_factors_gbc(dset, 5, 7),
    count_factors_gbc(dset, 8, 12),
    count_factors_gbc(dset, 13, 25),
    count_factors_gbc(dset, 26, 100),
    count_factors_gbc(dset, 101, Inf))
}

skew <- function(v) {
  if(!is.null(v$num_3q)) {
    v$num_3qu <- v$num_3q
  }
  if(!is.null(v$num_1q)) {
    v$num_1qu <- v$num_1q
  }
  if(v$num_3qu < v$num_median) {
    v$num_3qu <- v$num_median
  }
  if(v$num_1qu > v$num_median) {
    v$num_1qu <- v$num_median
  }
  if(is.null(v$num_3qu) || is.null(v$num_1qu)) {
    return(NA)
  } else if(is.null(v$num_median)) {
    return(NA)
  } else if(v$num_3qu != v$num_1qu) {
    (v$num_3qu - 2*v$num_median + v$num_1qu) / (v$num_3qu - v$num_1qu)
  } else if(is.null(v$num_mean)){
    0
  } else if (v$num_mean != v$num_median){
    1
  } else {
    0
  }
}

count_nums_skewness <- function(dset) {
  vs <- dset$variables
  skewnesses <- unlist(lapply(vs, function(v) ifelse(v$type == "numerical", skew(v), -10)))
  #print(skewnesses)
  skewnesses <- skewnesses[skewnesses!=-10]
  #print(skewnesses)
  parted <- cut(abs(skewnesses), breaks = c(seq(0, 0.9, 0.1), 1.1), ordered_result = TRUE, include.lowest = TRUE)
  unlist(lapply(levels(parted), function(lvl) sum(parted == lvl)))
}

compare_datasets <- function(dataset_info, r_dataset_info) {
  ds_vec <- c(count_factors_range(dataset_info), count_nums_skewness(dataset_info))
  rs_vec <- c(count_factors_range(r_dataset_info), count_nums_skewness(r_dataset_info))
  sqrt(sum((ds_vec-rs_vec)^2))
}

compare_datasets_v2 <- function(dataset_info, r_dataset_info) {
  ds_vec <- c(count_factors_range(dataset_info), count_nums_skewness(dataset_info))
  rs_vec <- c(count_factors_range(r_dataset_info), count_nums_skewness(r_dataset_info))
  vec <- ds_vec/rs_vec
  # jeśli 0/0, to otrzymujemy NaN, a chcemy 1
  vec[is.nan(vec)] <- 1
  # wyrównanie do [0, 1]
  vec[vec > 1] <- 1/vec[vec > 1]
  mean(vec)
}

compare_datasets_scaled <- function(dataset_info, r_dataset_inf) {
  1- exp(-compare_datasets(dataset_info, r_dataset_info))
}
