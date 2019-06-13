library(dplyr)
library(DataExplorer)
library(reader)
library(tidyr)
library(mlr)
library(readr)

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

# One-hot encoding Anna

oneHot <- function(d, uni) {
  coln <- paste("Anna", uni, sep="_")
  for(i in 1:length(uni)){
    d[coln[i]] <- ifelse(d$Anna == uni[i], 1, 0)
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
           "Antonina",
           "Lena")
  coln <- paste("Zero", uni, sep="_")
  for(i in 1:length(uni)){
    d[coln[i]] <- ifelse(d[,uni[i]] == 0, 1, 0)
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

# dodanie clusteryzowanej zmiennej ???

cluster <- function(d) {
  d
}

##################################################
##################### TSNE #######################
##################################################

library(tsne)

# Przygotowanie danych do tsne
tsneData <- train %>% drop_columns(1) %>% data.matrix %>% scale

colnames(tsneData) <- NULL

# Dist

tsneRes2 <- tsne(tsneData)

t(tsneData) %*% tsneRes2

# save(tsneRes, file="tsneRes2.rda")

load("tsneRes2.rda")

plot(tsneRes)

# hclust 
library(genie)
tree <- hclust2(dist(tsneRes), thresholdGini = 0.9)
labels <- cutree(tree, 10)

plot(tsneRes, col = labels, pch = 16)

# Podział zbioru 6
plot(tsneRes[labels == 6,])

km6 <- kmeans(tsneRes[labels == 6,], 2)

plot(tsneRes[labels == 6,], col = km6$cluster)

# centers

centers <- rbind(sapply(1:5, function(i) {tsneRes[labels == i,] %>% apply(2, mean)}) %>% t,
                 km6$centers)

rownames(centers) <- NULL

plot(tsneRes, col = labels)
points(centers, pch = 16, cex = 5, col = "seagreen")


# centers in original data
library(pdist)
centersOriginal <- rbind(sapply(1:5, function(i) {tsneData[labels == i,] %>% apply(2, mean)}) %>% t,
                 sapply(1:2, function(i) {(tsneData[labels == 6,])[km6$cluster == i,] %>% apply(2, mean)}) %>% t)


labelsOriginal <- apply(as.matrix(pdist(tsneData, centersOriginal)), 1, which.min)

plot(tsneRes, col = labels)
plot(tsneRes, col = labelsOriginal)


unique(labelsOriginal)

# Plots

library(ggplot2)


# Nowe labels

labelsTsne <- labels
labelsTsne[labelsTsne == 10] <- 1 
labelsTsne[labelsTsne == 9] <- 1 
labelsTsne[labelsTsne == 8] <- 2
labelsTsne[labelsTsne == 7] <- 1

labelsTsne[labelsTsne == 6] <- km6$cluster + 5

plot(tsneRes, col = labelsTsne)

dataToPlot <- data.frame(tsneRes)
colnames(dataToPlot) <- c('x', 'y')

# tsne no labels
  
tsnePlotNoLabels <- ggplot(dataToPlot, aes(x = x, y = y)) + 
  geom_point(colour = 'gray') +
  theme_minimal() +
  xlab("T-sne 1") +
  ylab("T-sne 2") +
  labs(colour = "Classes") +
  coord_equal() + 
  ggtitle("T-sne")

# hclust
tsnePlotHClust <- ggplot(dataToPlot, aes(x = x, y = y, colour = labels %>% as.factor())) + 
  geom_point() +
  theme_minimal() +
  xlab("T-sne 1") +
  ylab("T-sne 2") +
  labs(colour = "Classes") +
  coord_equal() + 
  ggtitle("T-sne with labels set by hclust2")


# by hand
tsnePlotByHand <- ggplot(dataToPlot, aes(x = x, y = y, colour = labelsTsne %>% as.factor())) + 
  geom_point() +
  theme_minimal() +
  xlab("T-sne 1") +
  ylab("T-sne 2") +
  labs(colour = "Classes") +
  coord_equal() + 
  ggtitle("T-sne with labels set by hand")

# centroids
tsnePlotCentroids <- ggplot(dataToPlot, aes(x = x, y = y, colour = labelsOriginal %>% as.factor())) + 
  geom_point() +
  theme_minimal() +
  xlab("T-sne 1") +
  ylab("T-sne 2") +
  labs(colour = "Classes") +
  coord_equal() + 
  ggtitle("T-sne with labels based on centroids")

save(centersOriginal,
     labelsTsne,
     labelsOriginal,
     tsneData,
     tsneRes,
     tsnePlotNoLabels,
     tsnePlotCentroids,
     tsnePlotByHand,
     tsnePlotHClust,
     file = "tsne_dane.rda")

