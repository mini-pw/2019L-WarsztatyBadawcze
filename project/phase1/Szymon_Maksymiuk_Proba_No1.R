library(mlr)
library(dplyr)


train <- select(read.csv("train.csv", sep=";"), -c(Zuzanna, Julia, Oliwia, Maria, Nikola, Gabriela))
test <- select(read.csv("WarsztatyBadawcze_test.csv", sep=";"), -c(Zuzanna, Julia, Oliwia, Maria, Nikola, Gabriela))

train$Aleksandra <- as.factor(train$Aleksandra)
test$Aleksandra <- as.factor(test$Aleksandra)
train$Natalia <- as.factor(train$Natalia)
test$Natalia <- as.factor(test$Natalia)
train$Nadia <- as.factor(train$Nadia)
test$Nadia <- as.factor(test$Nadia)
train$Pola <- as.factor(train$Pola)
test$Pola <- as.factor(test$Pola)
train$Liliana <- as.factor(train$Liliana)
test$Liliana <- as.factor(test$Liliana)

task <- makeClassifTask(id = "wb", data = train, target = "Y")
lrn <- makeLearner("classif.svm", predict.type = "prob", par.vals = list(cost = 682.478, gamma = 0.005))

model <- train(lrn, task)
pred <- predict(model, newdata=test)
write.csv(prediction$data$prob.TRUE, "preds.csv", row.names = FALSE)


