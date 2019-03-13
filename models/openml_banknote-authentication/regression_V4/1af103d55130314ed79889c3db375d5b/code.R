#:# libraries
library(digest)
library(OpenML)
library(caret)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
banknote_authentication <- getOMLDataSet(data.id = 1462L)
banknote <- banknote_authentication$data
head(banknote)


#:# preprocessing
head(banknote)

#:# model
regr_bag <- train(V4 ~ ., data = banknote, method = "svmLinear")

#:# hash 
#:# 3f3bc97b830b17824a97c54cbb7ebaad
hash <- digest(regr_bag)
hash

#:# audit
train_control <- trainControl(method="cv", number=5)
regr_bag_cv <- train(V4 ~ ., data = banknote, method = "svmLinear",
  trControl = train_control,
  metric = "RMSE")
print(regr_bag_cv)



#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()