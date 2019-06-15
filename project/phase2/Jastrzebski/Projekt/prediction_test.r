library(mlr)
library(dplyr)

ranger <- makeLearner("classif.ranger",
                      predict.type = "prob")

plot(iris[,1:4], col = as.numeric(iris$Species), pch=16)

plot(iris[,1:4],
     col = ifelse(as.numeric(iris$Species) == 2, 1, 2),
     pch=16)

I <- iris
I$Species <- ifelse(as.numeric(iris$Species) == 2, TRUE, FALSE)

task <- makeClassifTask(id = "iris",
                        data = I,
                        target = "Species")

cv <- makeResampleDesc(method = "CV",
                       iters = 5)

# Normalnie

r <- resample(ranger, 
              task,
              cv,
              measures = list(auc, acc, f1))

# teraz tunning

ps <- makeParamSet(
  makeIntegerParam("mtry", lower = 1, upper = 4),
  makeIntegerParam("num.trees", lower = 1, upper = 3000)
)

ctrl <- makeTuneControlGrid()

res <- tuneParams(ranger, 
                  task,
                  resampling = cv,
                  measures = list(auc),
                  par.set = ps,
                  control = ctrl)

lrn <- setHyperPars(ranger, par.vals = res$x)

model <- train(lrn, task)

prediction <- predict(model, newdata = I)

prediction$data$response





