### Wczytanie zbiorów
train <- read.csv2("train.csv")
test <- read.csv2("WarsztatyBadawcze_test.csv")

### Standaryzacja
# Train
Y1 <- train$Y
train <- train[ , -which(names(train) %in% c("Y", "Zuzanna", "Oliwia", "Nikola"))]
x1 <- sapply(train,unique,2)
names1 <- names(which(lapply(x1, length)>2))
temp_df1 <- train[names1]
temp_df2 <- train[-which(names(train) %in% names1)]
temp1 <- scale(temp_df1)
scaled_train <- cbind(temp1,temp_df2)
train <- cbind(Y1,scaled_train)
names(train)[1] <- "Y"

# Test
Y2 <- test$Y
test <- test[ , -which(names(test) %in% c("Y", "Zuzanna", "Oliwia", "Nikola"))]
x2 <- sapply(test,unique,2)
names2 <- names(which(lapply(x2, length)>2))
temp2_df1 <- test[names2]
temp2_df2 <- test[-which(names(test) %in% names2)]
temp2 <- scale(temp2_df1)
scaled_test <- cbind(temp2,temp2_df2)
test <- cbind(Y2,scaled_test)
names(test)[1] <- "Y"

### Biblioteki
library(mlr)

### Model
task <- makeClassifTask(id = "task", data = train, target = "Y")
lrn <- makeLearner("classif.svm", cost=100, gamma=0, predict.type = "prob")
trn <- mlr::train(lrn,task)
prd <- predict(trn,newdata=test)

result <- prd$data$prob.TRUE

write.csv2(result,"Wichrowska_Wachulec_result_phase2.csv",row.names = FALSE)
# result <- read.csv2("Wichrowska_Wachulec_result.csv")
