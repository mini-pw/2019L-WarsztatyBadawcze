#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(caret)
library(MLmetrics)

#:# config
set.seed(1)

#:# data
art_char_set <- getOMLDataSet(data.id = 1459L) 
art_char <- art_char_set$data
head(art_char)

#:# preprocessing
art_char$Class <- factor(ifelse(art_char$Class == 1, "A",ifelse(art_char$Class==2, "B",ifelse(art_char$Class==3,"C",ifelse(art_char$Class==4, "D",ifelse(art_char$Class==5, "E",ifelse(art_char$Class==6, "F",ifelse(art_char$Class==7, "G",ifelse(art_char$Class==8, "H",ifelse(art_char$Class==9, "I","J"))))))))))
head(art_char)

#:# model
classif_glm <- train(Class ~ ., data = art_char, method = "glmnet",
                        tuneGrid = expand.grid(alpha = 0, lambda = 0.5))

#:# hash
#:# 2cfa4afcd80d23466ca3cd66a64f809f
hash <- digest(classif_glm)
hash

#:# audit 
train_control <- trainControl(method="cv", number=5,  classProbs = TRUE, summaryFunction = multiClassSummary, savePredictions = "final")
classif_glm_cv <- train(Class ~ ., data = art_char, method = "glmnet",
                        tuneGrid = expand.grid(alpha = 0, lambda = 0.0002343928),
                        metric = "logLoss",
                        preProc=c("center", "scale"),
                        trControl = train_control)
print(classif_glm_cv)

ACC <- classif_glm_cv$results[6]
ACC
AUC <- classif_glm_cv$results[4]
AUC
MeanSpecificity <- classif_glm_cv$results[10]
MeanSpecificity
MeanRecall <- classif_glm_cv$results[9]
MeanRecall
MeanPrecision <- classif_glm_cv$results[13]
MeanPrecision
MeanF1 <- classif_glm_cv$results[8]
MeanF1

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
