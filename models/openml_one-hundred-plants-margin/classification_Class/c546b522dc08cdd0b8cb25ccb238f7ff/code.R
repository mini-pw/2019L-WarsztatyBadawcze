#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(farff)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
plants_ds <- getOMLDataSet(data.id = 1491L)
plants <- plants_ds$data
head(plants)

#:# preprocessing
head(plants)

#:# model
classif_task <- makeClassifTask(id = "plants", data = plants, target = "Class")
classif_lrn <- makeLearner("classif.ranger", predict.type = "prob")

#:# hash 
#:# c546b522dc08cdd0b8cb25ccb238f7ff
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc))
aggr <- r$aggr


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
