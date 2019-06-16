library(dplyr)
library(DataExplorer)
library(reader)
library(tidyr)

data <- read.csv2("WarsztatyBadawcze_test.csv")

# create_report(data)

# plot_histogram(data)

# Pelna korelacja
data %>% select(Gabriela, Zuzanna) %>% summarise(sum(Gabriela != Zuzanna))
data %>% summarise(sum(Gabriela != Julia))
data %>% summarise(sum(Gabriela != Aleksandra))
data %>% summarise(sum(Gabriela != Oliwia))
data %>% summarise(sum(Gabriela != Maria))
data %>% summarise(sum(Gabriela != Pola))
data %>% summarise(sum(Gabriela != Nikola))
data %>% summarise(sum(Gabriela != Gabriela))

data %>% summarise(sum(Aleksandra != Pola))

# Wniosek... ? Nie wiadomo, czy te zmienne beda skorelowane w pelnym zbiorze.
# istnieja jakies sladowe róznice...
# zobaczmy te wiersze

data %>% filter(Gabriela != Pola)

# Wygladaja ok

cordata <- cor(data)

cordataattr <- attributes(cordata)

cordata <- data.frame(row = rep(cordataattr$dimnames[[1]], each = 23),
           col = rep(cordataattr$dimnames[[1]], times = 23),
           val = as.vector(cordata))

cordata %>% filter(val > 0.999, row != col) %>% unique()
cordata %>% filter(val < -0.9, row != col) %>% unique()

# Ok, czyli wiemy, które kolumny sa potencjalnie smieciowe.
# Propozycja: scalenie + dla tych o prawie pelnej korelacji 
# kolumna gdzie sie róznia?

non01 <- data %>% select(Anna, Laura, Antonina, Emilia, Wiktoria,
                         Alicja, Amelia, Zofia, Hanna, Maja, Lena)


# plot(non01)

# wartosci unikalne

uniques <- mapply(function(i)  unique(data[i]), colnames(data))
uniques


# Przeksztalcenia logarytmiczne

hist(log(non01$Hanna))

(non01$Hanna == 0) %>% sum


hist(log(non01$Amelia))

hist(log(non01$Lena))

hist(log(non01$Laura))

hist(log(non01$Antonina))

hist(log(non01$Emilia + 1))

hist(log(non01$Maja + 1))

hist(log(non01$Maja))

hist(log(-non01$Zofia + 101, 1.1))

non01 %>% filter(Zofia == 100)

non01 %>% filter(Amelia == 0)

sort(table(non01$Wiktoria))

# Bez dziwnych danych

weird <- non01 %>% filter(Wiktoria %in% c(0, 50, 100))
plot(weird)

nonWeird <- non01 %>% filter(! Wiktoria %in% c(0, 50, 100) )

plot_scatterplot(nonWeird, by="Wiktoria")



nonWeird %>% filter(Amelia > 50) %>% summarise(n())


# Próba klasteryzacji

library(genie)
h <- hclust2(objects = as.matrix(non01[,2:11]))

plot(non01[,2:11], col=cutree(h, 2))

# z normalizacja

normalised <- non01[,2:11]
for(i in colnames(non01[,2:11])){
  normalised[i] <- normalised[i] - min(normalised[i])
  normalised[i] <- normalised[i]/max(normalised[i])
}

hist(normalised$Maja)
hist(log(log(log(normalised$Alicja + 1) + 1) + 1))

normalised$Maja <- log(normalised$Maja + 0.15)
normalised$Zofia <- log(1-normalised$Zofia + 0.01)
normalised$Alicja <- log(normalised$Alicja + 1)
#normalised$Maja <- log(normalised$Maja + 1)


# h2 <- hclust2(objects = as.matrix(normalised), thresholdGini = 0.1)
# 
# plot(normalised, col = cutree(h2, 2))
# 
# cutree(h2,2) %>% table
# 
# # hclust na logData
# 
# h3 <- genie::hclust2(objects = scale(as.matrix(logData[,2:23])))
# 
# cutree(h3,2) %>% table
# 
# plot(new_super_duper$Aga,
#      new_super_duper$Iga,
#      col = cutree(h3,15),
#      pch=16)
# 
# # super_duper
# 
# h4 <- hclust2(objects = scale(as.matrix(new_super_duper[,2:23])))
# cutree(h4,2) %>% table
# plot(new_super_duper$Aga,
#      new_super_duper$Iga,
#      col = cutree(h4,2),
#      pch=16)
# 
# plot(h4)



# PCA

pca <- prcomp(normalised, center=TRUE, scale. = TRUE)

summary(pca)

library(devtools)
library(ggbiplot)

ggbiplot(pca, choices = c(1,4))
ggbiplot(pca, choices = c(3,2))



# PCA2

pca2 <- prcomp(data[,2:23], center=TRUE, scale. = TRUE)

summary(pca2)

ggbiplot(pca2, choices = c(2,3))

ggbiplot(pca, choices=c(2,3), aes(color = cutree(h, 2)))


# PCA3

logData <- data
# hist(log(logData$Maja + 1))
logData$Maja <- log(logData$Maja + 1)
# hist(log(101-logData$Zofia))
logData$Zofia <- log(101-logData$Zofia)
hist(logData$Zofia)

# hist(log(log(log(log(log(logData$Alicja + 1)+1) + 1) + 1) + 1))
# # to nie ma sensu, trzeba dodac kolumne 0wZofia
# 
hist(log(logData$Alicja, base = 400), breaks = 40)
# logData$Alicja <- log(normalised$Alicja + 1)

hist(log(logData$Emilia + 1))
# Emilia to samo, ale jednak zrobimy log
logData$Emilia <- log(logData$Emilia+1)

pca3 <- prcomp(logData[,2:23], center = TRUE, scale. = TRUE)
summary(pca3)

# Prosze Panstwa! Oto mis!
ggbiplot(pca3)

# c:

# Dodanie tego do datasetu

pca3$rotation[,"PC2"] %>% length

## Mala analizka sigmoid
sigmoid <- function(x) {1/(1+exp(-x))}
x <- seq(from = -1, to = 1, length.out = 1000)
plot(x,sigmoid(20*(x - 0.1)))


## Ploty
str(pca)

new_super_duper <- cbind(logData,
                         Jagoda = sigmoid(20*(scale(as.matrix(logData[,2:23])) %*% pca3$rotation[,"PC2"] - 0.1)),
                         Iga = scale(as.matrix(logData[,2:23])) %*% pca3$rotation[,"PC2"],
                         Aga = scale(as.matrix(logData[,2:23])) %*% pca3$rotation[,"PC1"])

new_super_duper %>% summarise( asdf = mean((Liliana - Jagoda)^2), fdsa = mean((Liliana - 1 + Jagoda)^2)  )

plot(new_super_duper$Aga, new_super_duper$Iga, col = ifelse(round(new_super_duper$Jagoda) == 1, "firebrick", "seagreen"), pch=16)

ifelse(round(new_super_duper$Jagoda) == 1, "firebrick", "seagreen") %>% 
  table

# Czas swietowania








