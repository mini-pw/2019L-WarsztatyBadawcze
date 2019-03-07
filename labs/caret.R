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
train_control <- trainControl(method="cv", number=5, classProbs = TRUE, summaryFunction = twoClassSummary)
classif <- train(selector ~ ., data=liver, method="gbm", trControl=train_control, metric="AUC")
classif


regr_rf <- train(drinks ~ ., data = liver[,c(1,2,-1)], method = "ranger", tuneGrid = expand.grid(
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
  trControl = train_control,
  metric = "RMSE")
print(regr_rf_cv)
RMSE <-regr_rf_cv$results$RMSE
MSE <- RMSE^2
MSE

# Zadanie
# Dopasować model klasyfikacyjny przewidyjący zmienną selector.
# Na podstawie CV sprawdzić jego AUC, Accuracy, Sensitivity, Specisivity i F1.





