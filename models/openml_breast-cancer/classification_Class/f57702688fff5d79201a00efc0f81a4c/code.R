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
levels(dat$Class) <- c("y", "n")

#:# model
classif_trn <- train(Class ~ ., data = dat, method = "treebag")

#:# hash 
#:# f57702688fff5d79201a00efc0f81a4c
hash <- digest(list(Class ~ ., dat, "treebag", NULL))
hash

#:# audit
set.seed(123, "L'Ecuyer")
ctrl <- trainControl(method="cv", 
                     number=5, 
                     classProbs = TRUE, 
                     summaryFunction = twoClassSummary)
classif_trn_ctr <- train(Class ~ ., data = dat, method = "treebag",
  trControl = ctrl,
  metric = "ROC")
print(classif_trn_ctr)
cm <- confusionMatrix(classif_trn_ctr)


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink() 
