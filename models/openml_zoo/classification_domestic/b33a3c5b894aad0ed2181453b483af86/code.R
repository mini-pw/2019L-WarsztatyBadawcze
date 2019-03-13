#:# libraries
library(digest)
library(caret)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
zoo <- getOMLDataSet(data.id = 62L)
dat <- zoo$data
head(dat)

#:# preprocessing
head(dat)
dat <- na.omit(dat)

#:# model
classif_trn <- train(domestic ~ ., data = dat, method = "gaussprPoly", seed = 123)
classif_trn$times <- NULL

#:# hash 
#:# b33a3c5b894aad0ed2181453b483af86
hash <- digest(classif_trn)
hash

#:# audit
set.seed(123, "L'Ecuyer")
ctrl <- trainControl(method="cv", number=5, classProbs = TRUE, summaryFunction = twoClassSummary)
classif_trn_ctr <- train(domestic ~ ., data = dat, method = "gaussprPoly",
                         seed = 123,
                         trControl = ctrl,
                         metric = "RMSE")
print(classif_trn_ctr)
cm <- confusionMatrix(classif_trn_ctr)
cm
#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink() 