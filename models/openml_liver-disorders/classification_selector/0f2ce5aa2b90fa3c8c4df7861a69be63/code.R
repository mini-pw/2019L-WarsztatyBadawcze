#:# libraries
library(digest)
library(OpenML)
library(caret)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
liver_disorders <- getOMLDataSet(data.id = 8L)
liver <- liver_disorders$data
head(liver)

#:# preprocessing
head(liver)
a <- rep("a", length.out=nrow(liver))
a[liver$selector==2] <- "b"
a <- as.factor(a)
liver$selector <- a
#:# model
classif_bart <- train(selector ~ ., data = liver, method = "bartMachine", tuneGrid = expand.grid(
  num_trees = 50, 
  k = 3,
  alpha = 0.95,
  beta = 2,
  nu = 2),
  seed = 123)

#:# hash 
#:# 0f2ce5aa2b90fa3c8c4df7861a69be63
hash <- digest(classif_bart)
hash

#:# audit
set.seed(123, "L'Ecuyer")
train_control_ROC <- trainControl(method="cv", number=5, classProbs = TRUE, summaryFunction = twoClassSummary)
classif_bart_cv_ROC <- train(selector ~ ., data = liver, method = "bartMachine", tuneGrid = expand.grid(
  num_trees = 50, 
  k = 3,
  alpha = 0.95,
  beta = 2,
  nu = 2),
  seed = 123,
  trControl = train_control_ROC,
  metric = "ROC")
print(classif_bart_cv_ROC)
confusionMatrix(classif_bart_cv_ROC)


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()