#:# libraries
library(digest)
library(OpenML)
library(caret)

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
#:# 03f5224ae2118b63919cb1dbe9b52d0b
hash <- digest(list(Class ~ .,art_char,"glmnet",expand.grid(alpha = 0, lambda = 0.5)))
hash

#:# audit 
train_control <- trainControl(method="cv", number=5,  classProbs = TRUE, summaryFunction = multiClassSummary, savePredictions = "final")
classif_glm_cv <- train(Class ~ ., data = art_char, method = "glmnet",
                        tuneGrid = expand.grid(alpha = 0, lambda = 0.5),
                        metric = "logLoss",
                        preProc=c("center", "scale"),
                        trControl = train_control)
print(classif_glm_cv)

ACC <- classif_glm_cv$results[6]
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
