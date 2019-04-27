library(mlr)

train <- read.csv("train.csv", sep=";")
test <- read.csv("WarsztatyBadawcze_test.csv", sep=";")

classif_task <- makeClassifTask(id = "projekt", data = train, target = "Y")
classif_learner <- makeLearner("classif.ada", predict.type = "prob",
                               par.vals = list(loss = "exponential", type = "discrete", iter= 55,
                                               nu= 0.1, bag.frac= 0.5, model.coef= TRUE, bag.shift= FALSE,
                                               max.iter= 50, delta= 1e-10, verbose= F, minsplit= 25, minbucket= 9,
                                               cp= 0.01, maxcompete= 4, maxsurrogate= 5, usesurrogate= 2,
                                               surrogatestyle= 0, maxdepth= 30, xval= 0))

model <- train(classif_learner, classif_task)
pred <- predict(model, newdata=test)
answer <- as.data.frame(pred)$prob.1

write.csv(answer, "odpowiedziMS.csv", row.names = FALSE)