#install.packages("OpenML")
#install.packages('caret")

library(OpenML)
library(caret)

set.seed(1)

# pobranie danych
liver_disorders <- getOMLDataSet(data.id = 8L)
liver <- liver_disorders$data
head(liver)

# model
# https://topepo.github.io/caret/available-models.html
regr_rf <- train(drinks ~ ., data = liver, method = "ranger", tuneGrid = expand.grid(
                                                                mtry = 3, 
                                                                splitrule = "variance",
                                                                min.node.size = 5))

# jak sprawdzic mozliwe parametry
modelLookup("ranger")
regr_rf$modelInfo$parameters
regr_rf$bestTune

# audyt modelu
train_control <- trainControl(method="cv", number=5)
# w expandgrid nalezy zdefiniowac wszystkie mozliwe parametry modelu
regr_rf_cv <- train(drinks ~ ., data = liver, method = "ranger", tuneGrid = expand.grid(
                                                                  mtry = 3, 
                                                                  splitrule = "variance",
                                                                  min.node.size = 5),
   metric = "RMSE")
print(regr_gbm_cv)
RMSE <-regr_rf_cv$results$RMSE
MSE <- RMSE^2
MSE

# Zadanie
# Dopasować model klasyfikacyjny, np drzewo lub regresję logistyczną i na podstawie CV sprawdzić jego MSE.






