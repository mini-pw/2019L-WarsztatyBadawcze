#:# libraries
library(digest)
library(OpenML)
library(caret)

#:# config
set.seed(1)

#:# data
diabetes_set <- getOMLDataSet(data.id = 37L) 
diabetes <- diabetes_set$data
head(diabetes)

#:# preprocessing
head(diabetes)

#:# model
classif_glm <- train(class ~ ., data = diabetes, method = "glm", family=binomial())

#:# hash
#:# cbfae3e0a4a6bed24e4bd29253c1e4e9
hash <- digest(list(class ~ ., diabetes, "glm",NULL,family=binomial()))
hash

#:# audit 
train_control <- trainControl(method="cv", number=5,  classProbs = TRUE, summaryFunction = multiClassSummary, savePredictions = "final")
classif_glm_cv <- train(class ~ ., data = diabetes, method = "glm",family=binomial(),
                        trControl = train_control)
print(classif_glm_cv)

ACC <- classif_glm_cv$results[5]
ACC
AUC <- classif_glm_cv$results[3]
AUC
Specificity <- classif_glm_cv$results[9]
Specificity
Recall <- classif_glm_cv$results[8]
Recall
Precision <- classif_glm_cv$results[12]
Precision
F1 <- classif_glm_cv$results[7]
F1

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
