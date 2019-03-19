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

#:# hash
#:# f8ae00a6a682727f96b301693f8fd631
hash <- digest(list(company2 ~ .,data,"M5",expand.grid(pruned="Yes",
                                                       smoothed="No",
                                                       rules="No")))
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