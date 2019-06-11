library(mlr)
require(randomForestSRC)
train <- read.csv2("train.csv")
test <- read.csv2("WarsztatyBadawcze_test.csv")

task <- makeClassifTask(id="wb", train, target = 'Y')

learner <- makeLearner("classif.randomForestSRC", predict.type='prob', par.vals = list('mtry' = 5, 'nodesize' = 7))

trained <- train(learner, task)

prediction <- predict(trained, newdata=test)

write.csv(prediction$data$prob.TRUE, "out.csv", row.names = FALSE)
