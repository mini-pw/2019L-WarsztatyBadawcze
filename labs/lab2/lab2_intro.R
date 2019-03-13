n <- 200
x1 <- rgamma(n, 5, 2)
x2 <- runif(n)
x3 <- rnorm(n)
eps <- rnorm(n, 0, 1)

y <- 2 + x1 + 42 * x2 - exp(pi) * x3 + eps

df <- data.frame(y, x1, x2, x3)

model <- lm(y~., df)
model
summary(model)

new <- data.frame(x1 =1, x2 = 2, x3 = 3)


predict(model, new)

pred <- predict(model)

(MSE <- sum((y - pred)^2)/n)

library(rpart)

tree <- rpart(y~., df)
summary(tree)
plot(tree)

pred_tree <- predict(tree)
(MSE <- sum((y - pred_tree)^2)/n)



library(MASS)

data("Pima.te")

class(Pima.te$type)

tree <- rpart(type~., Pima.te)
pred_tree <- predict(tree)
head(pred_tree)
class_tree <- round(pred_tree[ ,2])
# class_tree <- pred_tree[ ,2] > 0.5
class_tree <- ifelse(pred_tree[ ,2] > 0.5, "Yes", "No")
class_tree

Acc_tree = sum(class_tree == Pima.te$type) / nrow(Pima.te)
Acc_tree

library(pROC)
roc_obj <- roc(Pima.te$type, pred_tree[,2])
auc(roc_obj)


model_glm <- glm(type~., Pima.te, family = "binomial")
model_glm

pred_glm <- predict(model_glm, type = "response")
pred_glm
class_glm <- ifelse(pred_glm > 0.5, "Yes", "No")

Acc_glm = sum(class_glm == Pima.te$type) / nrow(Pima.te)
Acc_glm


library(e1071)
model_svm <- svm(type~., Pima.te)
pred_svm <- predict(model_svm)


