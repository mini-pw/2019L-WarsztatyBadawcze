library(mlr)
library(dplyr)
library(mlrMBO)

set.seed(1)

train <- read.csv("train.csv", sep = ";")
test <- read.csv("WarsztatyBadawcze_test.csv", sep = ";")

classifTask <- makeClassifTask(data = train, target = "Y")
classifLrn <- makeLearner("classif.ksvm", predict.type = "prob", par.vals = list(kernel = "polydot", C = 4.902217))

trained <- train(classifLrn1, classifTask)
pred <- predict(trained, newdata = test)
temp <- getPredictionProbabilities(pred)
write.csv(temp, file = "LukaszBrzozowski.csv")