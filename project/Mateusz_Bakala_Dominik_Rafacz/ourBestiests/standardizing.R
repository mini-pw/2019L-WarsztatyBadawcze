library(mlr)

normalize_all <- function(dsets, targets) {
  lapply(dsets, function(dset) {
    list(data = normalizeFeatures(dset$data, target = dset$target, method = "range"),
         target = dset$target)
  })
} 
