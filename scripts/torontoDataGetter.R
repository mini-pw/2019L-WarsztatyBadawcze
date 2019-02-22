library(jsonlite)
library(purrr)
library(reader)

# MOCNO przekształcony kod funkcji summary.default
# właściwie to napisany od podstaw

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

getTorontoDataset <- function(name, added_by) {
  download.file(paste0("https://www.cs.toronto.edu/pub/neuron/delve/data/tarfiles/", name, ".tar.gz"), "tmp.tar.gz")
  untar("tmp.tar.gz")
  table <- read.table(paste0("./", name, "/Dataset.data.gz"))
  # nazwy kolumn:
  res <- readLines(paste0("./", name, "/Dataset.spec"))
  res <- res[-c(1:grep("Attributes:", res))]
  writeLines(res, "tmp.txt")
  cols <- read.table("tmp.txt", comment.char = "u")$V2
  file.remove("tmp.txt")
  colnames(table) <- cols
  
  # część kodu poniżej inspirowana: https://stackoverflow.com/questions/39168484/r-summary-to-parsable-format-preferable-json
  
  variables <- table %>% imap(dummary)
  notYetJson <- list(id = paste0("toronto_", name),
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
  json <- notYetJson %>% toJSON(auto_unbox = TRUE, pretty = TRUE)   # convert to JSON, make it legible
  dir.create(paste0("toronto_", name))
  write(json, paste0("./toronto_", name, "/dataset.json"))
}
