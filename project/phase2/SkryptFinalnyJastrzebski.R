library(dplyr)
library(DataExplorer)
library(reader)
library(tidyr)
library(mlr)
library(readr)
library(rJava)
options(java.parameters = "-Xmx5g")
library(bartMachine)


## Wczytanie danych

train <- read.csv2("train.csv")
train$Y <- rep(c(TRUE, FALSE))
test <- read.csv2("WarsztatyBadawcze_test.csv")

# Usuniecie niepotrzebnych zmiennych

usunNiepotrzebneZmienne <- function(d) {
  
  d %>% select(-Julia,
               -Aleksandra,
               -Oliwia,
               -Maria,
               -Pola,
               -Nikola,
               -Gabriela)
}

# To factor

doFactorow <- function(d) {
  d$Liliana <-d$Liliana %>% as.factor()
  d$Nadia <-d$Nadia %>% as.factor()
  d$Anna <-d$Anna %>% as.factor()
  d$Natalia <-d$Natalia %>% as.factor()
  d$Zuzanna <- d$Zuzanna %>% as.factor()
  d
}

# One-hot encoding Anna

oneHot <- function(d, uni) {
  coln <- paste("Anna", uni, sep="_")
  for(i in 1:length(uni)){
    d[coln[i]] <- ifelse(d$Anna == uni[i], 1, 0) %>% as.factor()
  }
  d
}

# Dodanie zmiennych 0wCzyms

czy0w <- function(d) {
  uni <- c("Zofia"   ,
           "Alicja"  ,
           "Maja"    ,
           "Emilia"  ,
           "Hanna"   ,
           "Antonina")
  coln <- paste("Zero", uni, sep="_")
  for(i in 1:length(uni)){
    d[coln[i]] <- ifelse(d[,uni[i]] == 0, 1, 0) %>% as.factor()
  }
  d
}

# Przeksztalcenia logarytmiczne

logItAll <- function(d) {
  d$Maja <- log(d$Maja + 1)
  d$Zofia <- log(101-d$Zofia)
  d$Emilia <- log(d$Emilia+1)
  d$Alicja <- log(d$Alicja+1)
  d
}

# Wyskalowanie

#### normalizeFeatures

# dodanie clusteryzowanej zmiennej
load("tsne_dane.rda")
library(pdist)
cluster <- function(d) {
  tr <- d %>% drop_columns("Y") %>% data.matrix
  
  scaled <- apply(tr, 1, function(r) (r - attr(tsneData,"scaled:center"))/attr(tsneData,"scaled:scale")) %>% t
  
  newColumns <- as.matrix(pdist(scaled, centersOriginal))

  newColumnsDataFrame <- data.frame(newColumns)

  colnames(newColumnsDataFrame)<-paste("Teresa", 1:7,sep='_')
  
  tsneDataFrame <- tsneRes %>% data.frame()
  
  colnames(tsneDataFrame) <- paste("Tina", 1:2, sep="_")
  
  cbind(d, newColumnsDataFrame)
}

# Dane
uni <- unique(train$Anna)

train %>%
  cluster %>%
  doFactorow %>% 
  usunNiepotrzebneZmienne %>% 
  logItAll %>%
  oneHot(uni) %>% 
  czy0w -> bujka

test %>%
  cluster %>%
  doFactorow %>% 
  usunNiepotrzebneZmienne %>% 
  logItAll %>% 
  oneHot(uni) %>% 
  czy0w -> bajka

# Klasyfikacja

ranger <- makeLearner("classif.bartMachine",
                      predict.type = "prob")

task <- makeClassifTask(id = "asdf",
                        data = bujka,
                        target = "Y")

model <- train(ranger, task)

prediction <- predict(model, newdata = bajka)

write_csv(prediction$data["prob.TRUE"],
          "prediction_bj.csv")





