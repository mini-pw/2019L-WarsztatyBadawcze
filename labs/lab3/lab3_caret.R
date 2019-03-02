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

regr_tree <- train(drinks ~ ., data = liver, method = "rpart2", tuneGrid = expand.grid(maxdepth = 5))

# jak sprawdzic mozliwe parametry
modelLookup("rpart")
regr_tree$modelInfo$parameters
regr_tree$bestTune

# audyt modelu
train_control <- trainControl(method="cv", number=5)
# w expandgrid nalezy zdefiniowac wszystkie mozliwe parametry modelu
regr_tree_cv <- train(drinks ~ ., data = liver, method = "rpart2", tuneGrid = expand.grid(maxdepth = 5), metric = "RMSE")
print(regr_tree_cv)
RMSE <-regr_tree_cv$results$RMSE
MSE <- RMSE^2
MSE

# Zadanie
# Dopasować model klasyfikacyjny, np drzewo lub regresję logistyczną i na podstawie CV sprawdzić jego MSE.






