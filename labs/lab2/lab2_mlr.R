#install.packages("OpenML")
#install.packages(mlr)

library(OpenML)
library(mlr)

set.seed(1)

# pobranie danych
liver_disorders <- getOMLDataSet(data.id = 8L)
liver <- liver_disorders$data
head(liver)

# model
regr_task = makeRegrTask(id = "lvr", data = liver, target = "drinks")
regr_lrn = makeLearner("regr.rpart", par.vals = list(maxdepth = 5))

# jak sprawdzic mozliwe parametry
getParamSet(regr_lrn)
helpLearnerParam(regr_lrn)
getHyperPars(regr_lrn)
?rpart::rpart.control


# audyt modelu
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse))
MSE <- r$aggr
MSE

listMeasures()
?listMeasures()
listMeasures(obj = "regr")

# Zadanie
# Dopasować model klasyfikacyjny, np drzewo lub regresję logistyczną i na podstawie CV sprawdzić jego Accuracy i AUC.





