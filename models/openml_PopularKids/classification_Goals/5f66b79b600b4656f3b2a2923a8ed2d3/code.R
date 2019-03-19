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
#:# 5f66b79b600b4656f3b2a2923a8ed2d3
hash <- digest(list(Goals ~ ., data,"LogitBoost",expand.grid(nIter=20)))
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