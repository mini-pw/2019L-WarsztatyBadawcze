#:# libraries
library(digest)
library(OpenML)
library(caret)
library(caTools)


#:# config
set.seed(943)


#:# data
dataSet <- getOMLDataSet(data.id = 1100L)
data <- dataSet$data

#:# preprocessing
head(data)
summary(data)

#:# model
classif <- train(Goals ~ ., data=data, method="LogitBoost", tuneGrid=expand.grid(nIter=20))
classif$times <- NULL  #zeby hash byl zawsze taki sam

#:# hash
#:# caf8e7688c79e1241dfa050eac9f3fe1
hash <- digest(classif)
hash


#:# audit
set.seed(943,"L'Ecuyer")
train_control <- trainControl(method="cv", number=5)

classif <- train(Goals ~ ., data=data, method="LogitBoost",trControl=train_control, 
                 tuneGrid=expand.grid(nIter=20))

classif$results$Accuracy

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()