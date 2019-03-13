#:# libraries
library(digest)
library(OpenML)
library(caret)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
wine <- getOMLDataSet(data.id = 40498L)
wine <- wine$data
head(wine)

#:# preprocessing
head(wine)

#:# model
class_rf <- train(Class ~ ., data = wine, method = "LMT", tuneGrid = expand.grid(
  iter = 10))

#:# hash 
#:# dba874065b1e2bbd2fdaae5b6fabea79
hash <- digest(class_rf)
hash

#:# audit
set.seed(123, "L'Ecuyer")
train_control <- trainControl(method="cv", number=5)
class_rf_cv <- train(Class ~ ., data = wine, method = "LMT", tuneGrid = expand.grid(
  iter = 10),
  trControl = train_control,
  metric = "Accuracy")
print(class_rf_cv)
confusionMatrix(class_rf_cv)


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()