#:# libraries
library(digest)
library(caret)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
geyser_ds <- getOMLDataSet(data.id = 712L)
geyser <- geyser_ds$data
head(geyser)

#:# preprocessing
head(geyser)

#:# model
regr_trn <- train(col_3 ~ ., data = geyser, method = "treebag")

#:# hash 
#:# e969aeb24ecf5f57be549b8cee168214
hash <- digest(list(col_3~., geyser, "treebag", NULL))
hash

#:# audit
set.seed(123, "L'Ecuyer")
ctrl <- trainControl(method="cv", number=5)
regr_trn_c <- train(col_3 ~ ., data = geyser, method = "treebag", trControl = ctrl, metric = "RMSE")
print(regr_trn_c)
regr_trn_c$results$RMSE^2

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
