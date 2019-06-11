#Made by Wojciech Bogucki & Karol Pysiak
library(mlr)

data_train <- read.csv("train.csv")
data_test <- read.csv("WarsztatyBadawcze_test.csv")

params <- list(K=2, L=7)

task <- makeClassifTask(id="task", data = data_train, target="Y")
learner <- makeLearner("classif.rotationForest", par.vals = params, predict.type = "prob")

model <- mlr::train(learner = learner, task = task)

prediction <- predict(model, newdata = data_test)

prob_true <- prediction$data$prob.TRUE

write.csv(prob_true, file="prob_true_Bogucki_Pysiak.csv", row.names = FALSE)