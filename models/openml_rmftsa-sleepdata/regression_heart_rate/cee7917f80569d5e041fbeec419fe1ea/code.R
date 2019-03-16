#:# libraries
library(digest)
library(caret)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
sleep <- getOMLDataSet(data.id = 679L)
dat <- sleep$data
head(dat)

#:# preprocessing
head(dat)
dat <- na.omit(dat)

#:# model
regr_trn <- train(heart_rate ~ ., data = dat, method = "rlm", seed = 123)
regr_trn$times <- NULL

#:# hash 
#:# cee7917f80569d5e041fbeec419fe1ea
hash <- digest(regr_trn)
hash

#:# audit
set.seed(123, "L'Ecuyer")
ctrl <- trainControl(method="cv", number=5)
regr_trn_ctr <- train(heart_rate ~ ., data = dat, method = "rlm",
                         seed = 123,
                         trControl = ctrl)
print(regr_trn_ctr)
cm <- confusionMatrix(regr_trn_ctr)
cm
#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink() 
