#:# libraries
library(caret)
library(digest)
library(OpenML)

#:# config
set.seed(1)

#:# data
data <- getOMLDataSet(data.id = 470L)
head(df)
df <- data$data

#:# preprocessing
head(df)
df <- df[, 1:8]

#:# model
classf <- train(Home.Away ~ ., data = df, method = "svmPoly", tuneGrid = expand.grid(
  degree = 1,
  scale = 1,
  C = 1
))
#:# hash
#:# 3ea466dae4197369912558011e56432d
hash <- digest(list(TIME ~ ., df, "ranger", expand.grid(
  mtry = 3, 
  splitrule = "variance",
  min.node.size = 5)))
hash

#:# audit
train_control <- trainControl(method="cv", number=5, classProbs = TRUE, summaryFunction = prSummary)
classf <- train(Home.Away ~ ., data = df, method = "svmPoly", tuneGrid = expand.grid(
  degree = 1,
  scale = 1,
  C = 1
),
  trControl = train_control,
  metric = "ROC",
  na.action = na.omit)

print(classf)
results <-classf$results
results
confusionMatrix(classf)
#prSummary(classf, lev = levels(df$Home.Away))


#:# session_info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()