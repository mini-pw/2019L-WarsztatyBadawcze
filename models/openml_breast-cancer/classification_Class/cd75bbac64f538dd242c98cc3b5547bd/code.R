#:# libraries
library(digest)
library(caret)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
breast_cancer <- getOMLDataSet(data.id = 13L)
dat <- breast_cancer$data
head(dat)

#:# preprocessing
head(dat)
dat <- na.omit(dat)
levels(dat$Class) <- c("n", "y")

#:# model
classif_trn <- train(Class ~ ., data = dat, method = "treebag", seed = 123)
classif_trn$times <- NULL

#:# hash 
#:# cd75bbac64f538dd242c98cc3b5547bd
hash <- digest(classif_trn)
hash

#:# audit
set.seed(123, "L'Ecuyer")
ctrl <- trainControl(method="cv", number=5, classProbs = TRUE, summaryFunction = twoClassSummary)
classif_trn_ctr <- train(Class ~ ., data = dat, method = "treebag",
  seed = 123,
  trControl = ctrl,
  metric = "ROC")
print(classif_trn_ctr)
cm <- confusionMatrix(classif_trn_ctr)


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink() 
