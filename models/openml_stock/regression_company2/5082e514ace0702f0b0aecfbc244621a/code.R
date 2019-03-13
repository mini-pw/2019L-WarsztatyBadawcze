#:# libraries
library(digest)
library(OpenML)
library(caret)



#:# config
set.seed(943)


#:# data
dataSet <- getOMLDataSet(data.id = 841L)
data <- dataSet$data

#:# preprocessing
head(data)
summary(data)

#:# model
regr <- train(company2 ~ ., data=data, method="M5", tuneGrid = expand.grid(pruned="Yes",
                                                                           smoothed="No",
                                                                           rules="No"))
regr$times <- NULL  #zeby hash byl zawsze taki sam
regr
modelLookup("HYFIS")
regr$modelInfo$parameters
regr$bestTune

#:# hash
#:# caf8e7688c79e1241dfa050eac9f3fe1
hash <- digest(regr)
hash


#:# audit

train_control <- trainControl(method="cv", number=5)

regr <- train(company2 ~ ., data=data, method="M5", trControl=train_control, tuneGrid = expand.grid(pruned="Yes",
                                                                           smoothed="No",
                                                                           rules="No"))

regr$results

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()