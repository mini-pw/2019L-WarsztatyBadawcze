source("genie.R")
test_mod <- read.csv("WarsztatyBadawcze_transformed.csv")

test_pca <- prcomp(test_mod, center = TRUE, scale. = TRUE) 

library(ggbiplot)
ggbiplot(pcobj = test_pca)

ginis<- c(0.15, 0.3, 0.4, 0.45, 0.5, 0.55, 0.6, 0.7, 0.85)
clust_genie <- lapply(ginis, function(x) genie(as.matrix(test_mod), 2, x))

ggplot(data = as.data.frame(cbind(test_pca$x,target = as.factor(clust_genie[[4]]))), 
       aes(x=PC2, y=PC3, color = target)) + 
  geom_point()


clust_met <- lapply(c("ward.D", "ward.D2", "single", "complete", "average",
                      "mcquitty", "median", "entroid"), function(met) {
  cutree(
    hclust(
      dist(
        as.matrix(test_mod), 
        method="euclidean"), 
      method = met), 
    k = 2)
})
hclust(test_mod, method = "single")

ggplot(data = as.data.frame(cbind(test_pca$x,target = as.factor(clust_met[[8]]))), 
       aes(x=PC1, y=PC2, color = target)) + 
  geom_point()


test_targetted <- cbind(test_mod, target = as.factor(clust_genie))
tsk <- mlr::makeClassifTask(id = "samclas", target = "target", data = test_targetted)
lrn <- mlr::makeLearner("classif.ranger", predict.type = "prob")
lrn2 <- mlr::makeLearner("classif.logreg", predict.type = "prob")
trnr <- mlr::resample(lrn2, tsk, mlr::cv5, measures = list(mlr::auc, mlr::acc, mlr::mmce), 
              show.info = TRUE)

trainind <- sample(1:4184, ceiling(4184*6/10), replace = FALSE)
testind <- setdiff(1:4184, trainind)
training <- train(lrn, tsk, subset = trainind)
training2 <- train(lrn2, tsk, subset = trainind)
predicting <- predict(training, tsk, subset = testind)
predicting2 <- predict(training2, tsk, subset = testind)

training$learner.model

getFeatureImportance(training)

custom_predict_classif <- function(object, newdata) {
  pred <- predict(object, newdata=newdata)
  response <- as.numeric(as.character(pred$data[,3]))
  return(response)
}

explainer = explain(training, data=test_targetted[trainind,-15], 
                    y=as.numeric(as.character(test_targetted[trainind, 15])), 
                    label= "ranger", predict_function = custom_predict_classif)
perf <- model_performance(explainer)
perf
vif <- variable_importance(explainer)
vif
plot(vif)
