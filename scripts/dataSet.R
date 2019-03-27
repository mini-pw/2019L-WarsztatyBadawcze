DataSet <- function(data, name, target = "", targetType = "") {
  ret <- list(data = data,
              name = name,
              target = target,
              targetType = targetType)
  class(ret) <- "DataSet"
  return(ret)
}

as.DataSet <- function(openMLData) {
  UseMethod("as.DataSet")
}

as.DataSet.OMLDataSet <- function(openMLData) {
  stopifnot("OMLDataSet" %in% class(openMLData))
  target <- openMLData$target.features
  if (is.null(target)) {
    target <- openMLData$default.target.attribute
  }
  DataSet(openMLData$data, openMLData$desc$name, target)
}

as.DataSet.default <- function() {
  # returns empty DataSet object
  DataSet(NULL, "", "")
}

print.DataSet <- function(dataSetObject) {
  if (dataSetObject$target == "") {
    cat(paste0(
      "DataSet of name \"", dataSetObject$name, "\"\n",
      "Target variable not specified\n\n",
      "Data head:\n"
    ))
  } else {
    cat(paste0(
      "DataSet of name \"", dataSetObject$name, "\"\n",
      "Target variable \"", dataSetObject$target, "\"\n\n",
      "Data head:\n"
    ))
  }
  print(head(dataSetObject$data))
}
