#:# libraries
library(OpenML)
library(caret)
library(digest)

#:# config
set.seed(1)

#:# data
auto_price <- getOMLDataSet(data.id = 745)
auto <- auto_price$data
auto$symboling <- droplevels(auto$symboling)
#:# model
classif_treebag <- train(symboling ~ ., data = auto, method = "treebag")

#:# hash 
#:# d1d0b3f54b6442e270e6424aedeccbc2
hash <- digest(list(symboling ~ ., auto, "treebag", NULL))
hash
#:# audit
train_control <- trainControl(method="cv", number=5)
classif_treebag_cv <- train(symboling ~ ., data = auto, method = "treebag",
                        trControl=train_control)
Acc <- (classif_treebag_cv$results)$Accuracy

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
