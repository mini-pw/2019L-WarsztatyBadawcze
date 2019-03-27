df1 <- read.csv("dataset.csv")

wynikiDE <- matrix(nrow = 0, ncol = 3)
wynikiBE <- matrix(nrow = 0, ncol = 3)

for(i in 1:10){
  set.seed(i)
  #DummyEncoding - rf
  
  dfDummy <- dummyVars("~.", data = df1)
  dfDummy <- data.frame(predict(dfDummy, newdata = df1))
  
  train_set <- sample_frac(dfDummy, 0.75)
  test_set <- setdiff(dfDummy, train_set)
  
  regr_rf <- caret::train(performance1~., data = train_set, method="rf", ntree = 100)
  
  p <- predict(regr_rf, newdata = test_set)
  wynikiDE <- rbind(wynikiDE, postResample(pred = p, obs = test_set$performance1))
  
  #BezEncodingu - rf
  
  train_set1 <- sample_frac(df1, 0.75)
  test_set1 <- setdiff(df1, train_set1)
  
  regr_rf1 <- caret::train(performance1~., data = train_set1, method = "rf", ntree = 100)
  
  p1 <- predict(regr_rf1, newdata = test_set1)
  wynikiBE <- rbind(wynikiBE, postResample(pred = p1, obs = test_set1$performance1))
  
}

wynikiTB <- matrix(nrow = 0, ncol = 3)
for(i in 1:10){
  set.seed(i)
  
  #BezEncodingu - treebag
  
  train_set1 <- sample_frac(df1, 0.75)
  test_set1 <- setdiff(df1, train_set1)
  head(train_set1)
  regr_rf1 <- caret::train(performance1~., data = train_set1, method = "treebag")
  
  p1 <- predict(regr_rf1, newdata = test_set1)
  wynikiTB <- rbind(wynikiTB, postResample(pred = p1, obs = test_set1$performance1))
  
}
wynikiB <- matrix(nrow = 0, ncol = 3)
for(i in 1:10){
  
  set.seed(i)
  
  #BezEncodingu - bayes
  
  train_set1 <- sample_frac(df1, 0.75)
  test_set1 <- setdiff(df1, train_set1)
  head(train_set1)
  regr_rf1 <- caret::train(performance1~., data = train_set1, method = "bayesglm")
  
  p1 <- predict(regr_rf1, newdata = test_set1)
  wynikiB <- rbind(wynikiB, postResample(pred = p1, obs = test_set1$performance1))
  
}

#Agregacja wyników

wynikiDE <- as.data.frame(wynikiDE)
wynikiBE <- as.data.frame(wynikiBE)
wynikiTB <- as.data.frame(wynikiTB)
wynikiB <- as.data.frame(wynikiB)

wynikiDEm <- c(mean(wynikiDE$RMSE), mean(wynikiDE$Rsquared), mean(wynikiDE$MAE))
wynikiBEm <- c(mean(wynikiBE$RMSE), mean(wynikiBE$Rsquared), mean(wynikiBE$MAE))
wynikiTBm <- c(mean(wynikiTB$RMSE), mean(wynikiTB$Rsquared), mean(wynikiTB$MAE))
wynikiBm <- c(mean(wynikiB$RMSE), mean(wynikiB$Rsquared), mean(wynikiB$MAE))
wyniki <- rbind(rbind(rbind(wynikiDEm, wynikiBEm), wynikiTBm), wynikiBm)
wyniki <- as.data.frame(wyniki)
colnames(wyniki) <- c("RMSE", "Rsquared", "MAE")
rownames(wyniki) <- c("RF Dummy", "RF", "Treebag", "BayesGLM")
write.csv(wyniki, "wynikiModeli.csv")
