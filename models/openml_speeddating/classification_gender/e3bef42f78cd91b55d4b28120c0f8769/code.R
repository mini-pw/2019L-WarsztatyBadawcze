#:# libraries
library(digest)
library(OpenML)
library(caret)

#:# config
set.seed(1)

#:# data
speeddating <- getOMLDataSet(data.id = 40536)
df <- speeddating$data
head(df)

#:# preprocessing
df <- na.omit(df)

#:# model
train_control <- trainControl(method="cv", number=5)
classif_rpart <- caret::train(gender ~ ., df, "rpart")

#:# hash 
#:# e3bef42f78cd91b55d4b28120c0f8769
hash <- digest(list(gender ~ ., df, "rpart"))
hash

#:# audit
acc <- classif_rpart$results$Accuracy

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
