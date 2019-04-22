source("standardizing.R")
dsets <- list()

library(OpenML)
temp <- getOMLDataSet(data.name = "boston")
dsets[[1]] <- list(data = temp$data, target = temp$target.features)

temp <- getOMLDataSet(data.name = "stock")
dsets[[2]] <- list(data = temp$data, target = temp$target.features)

temp <- getOMLDataSet(data.name = "house_8L")
dsets[[3]] <- list(data = temp$data, target = temp$target.features)

temp <- getOMLDataSet(data.name = "ilpd")
dsets[[4]] <- list(data = temp$data, target = temp$target.features)

#w tym folderze
dsets[[5]] <- list(data = read.csv(file = "pokemon.csv")[-1], target = "Legendary")

dsets <- normalize_all(dsets, targets)

