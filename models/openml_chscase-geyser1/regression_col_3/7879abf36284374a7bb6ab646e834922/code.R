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
#:# 7879abf36284374a7bb6ab646e834922
hash <- digest(geyser)
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
