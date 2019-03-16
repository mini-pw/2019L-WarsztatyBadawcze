#:# libraries
library(OpenML)
library(caret)
library(digest)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
auto_price <- getOMLDataSet(data.id = 745)
auto <- auto_price$data
auto$symboling <- droplevels(auto$symboling)
#:# model
classif_treebag <- train(symboling ~ ., data = auto, method = "treebag")

#:# hash 
#:# 55e4bb2e6d047bac9edbc29d5d74017b
hash <- digest(classif_treebag)

#:# audit
train_control <- trainControl(method="cv", number=5)
classif_treebag_cv <- train(symboling ~ ., data = auto, method = "treebag",
                        trControl=train_control)
Acc <- (classif_treebag_cv$results)$Accuracy

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
