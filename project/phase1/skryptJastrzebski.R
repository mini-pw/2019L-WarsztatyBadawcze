library(dplyr)
library(DataExplorer)
library(reader)
library(tidyr)
library(mlr)
library(readr)

## Wczytanie danych

train <- read.csv2("train.csv")
test <- read.csv2("WarsztatyBadawcze_test.csv")

# Usunięcie niepotrzebnych zmiennych

usunNiepotrzebneZmienne <- function(d) {
  
  d %>% select(-Julia,
               -Aleksandra,
               -Oliwia,
               -Maria,
               -Pola,
               -Nikola,
               -Gabriela)
}

# One-hot encoding Anna

oneHot <- function(d, uni) {
  coln <- paste("Anna", uni, sep="_")
  for(i in 1:length(uni)){
    d[coln[i]] <- ifelse(d$Anna == uni[i], 1, 0)
  }
  d
}

# Dodanie zmiennych 0wCzymś

czy0w <- function(d) {
  uni <- c("Zofia"   ,
           "Alicja"  ,
           "Maja"    ,
           "Emilia"  ,
           "Hanna"   ,
           "Antonina",
           "Lena")
  coln <- paste("Zero", uni, sep="_")
  for(i in 1:length(uni)){
    d[coln[i]] <- ifelse(d[,uni[i]] == 0, 1, 0)
  }
  d
}

# Przekształcenia logarytmiczne

logItAll <- function(d) {
  d$Maja <- log(d$Maja + 1)
  d$Zofia <- log(101-d$Zofia)
  d$Emilia <- log(d$Emilia+1)
  d$Alicja <- log(d$Alicja+1)
  d
}

# Wyskalowanie

#### normalizeFeatures

# dodanie super zmiennej

sigmoid <- function(x) {1/(1+exp(-x))}

getRotation <- function(d) {
  pca <- prcomp(d[,2:ncol(d)], center = TRUE, scale. = TRUE)
  pca$rotation[,"PC2"]
}

super_duper_feature <- function(d, rotation) {
  cbind(d,
        Jagoda = sigmoid(20*(scale(as.matrix(d[,2:ncol(d)])) %*% rotation  + 0.2) )#,
        #Iga = scale(as.matrix(d[,2:ncol(d)])) %*% rotation
        )
}

# dodanie clusteryzowanej zmiennej ???

cluster <- function(d) {
  h <- hclust2(
    objects = scale(
      as.matrix(
        d[ ,c("Zofia",
              "Alicja",
              "Maja",
              "Emilia",
              "Hanna",
              "Antonina",
              "Lena",
              "Amelia",
              "Wiktoria",
              "Laura")])))
  
  labels <- cutree(h,7)
  uni <- unique(labels)
  coln <- paste("Cluster", uni, sep="_")
  for(i in 1:length(uni)){
    d[coln[i]] <- ifelse(labels == uni[i], 1, 0)
  }
  d
}

# Dane
uni <- unique(train$Anna)


rotation <- c(-0.03229731,
              -0.24544593,
              -0.11541393,
              0.15347325,
              -0.11347819,
              -0.03127474,
              0.12582792,
              -0.02087280,
              0.11499572,
              0.54374337,
              -0.06027080,
              0.03642310,
              -0.39128052,
              -0.03527800,
              -0.57973141)

train %>% 
  usunNiepotrzebneZmienne %>% 
  logItAll %>% 
  super_duper_feature(rotation) %>% 
  oneHot(uni) %>% 
  czy0w %>% 
  cluster -> bujka

test %>% 
  usunNiepotrzebneZmienne %>% 
  logItAll %>% 
  super_duper_feature(rotation) %>% 
  oneHot(uni) %>% 
  czy0w %>% 
  cluster -> bajka

# Klasyfikacja

ranger <- makeLearner("classif.ranger",
                      predict.type = "prob")

task <- makeClassifTask(id = "asdf",
                        data = bujka,
                        target = "Y")

cv <- makeResampleDesc(method = "CV",
                       iters = 3)

ps <- makeParamSet(
  makeIntegerParam("mtry",
                   lower = 1,
                   upper = ncol(bujka) - 1),
  makeIntegerParam("num.trees",
                   lower = 1, 
                   upper = 700)
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

prediction <- predict(model, newdata = bajka)

write_csv(prediction$data["prob.TRUE"],
          "prediction_bj.csv")

















