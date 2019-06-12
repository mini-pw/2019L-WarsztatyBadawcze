library(mlr)
library(dplyr)

train <- read.csv("train.csv", sep=";")
train <- select(train, -c('Y', 'Zuzanna', "Oliwia", "Maria", "Nikola", "Gabriela", 'Pola'))
test <- read.csv("WarsztatyBadawcze_test.csv", sep=";")
test <- select(test, -c('Y', 'Zuzanna', "Oliwia", "Maria", "Nikola", "Gabriela", 'Pola'))

classif_task <- makeClassifTask(id = "projekt", data = train, target = "Y")
classif_learner <- makeLearner("classif.ada", predict.type = "prob")

model <- train(classif_learner, classif_task)
pred <- predict(model, newdata=test)
answer <- as.data.frame(pred)$prob.1

write.csv(answer, "odpowiedziMS.csv", row.names = FALSE)