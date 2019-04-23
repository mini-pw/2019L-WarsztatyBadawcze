library(readr)
library(DataExplorer)
library(dataMaid)
library(corrplot)
library(dplyr)

df <- read_delim("WarsztatyBadawcze_test.csv", delim = ";", 
                col_types = cols(
                Y = col_logical(),
                Zuzanna = col_logical(),
                Julia = col_logical(),
                Lena = col_double(),
                Maja = col_double(),
                Hanna = col_double(),
                Zofia = col_double(),
                Amelia = col_double(),
                Alicja = col_double(),
                Aleksandra = col_logical(),
                Natalia = col_logical(),
                Oliwia = col_logical(), 
                Maria = col_logical(),
                Wiktoria = col_double(),
                Emilia = col_double(),
                Antonina = col_double(),
                Laura = col_double(),
                Anna = col_double(),
                Nadia = col_logical(),
                Pola = col_logical(),
                Liliana = col_logical(),
                Nikola = col_logical(),
                Gabriela = col_logical()
              ))
head(df)
apply(df, 2, unique)
DataExplorer::plot_correlation(df)
k <- 0
duplicated_col <- logical(ncol(df))
for(i in 1:ncol(df)){
  for(j in i:ncol(df)){
    if(all(df[ , i] == df[ , j]) & i != j){
      print(paste0(c(k, " is equal: ", colnames(df)[i], colnames(df)[j], i, j )))
      k <- k + 1
      duplicated_col[j] <- TRUE
    }
  }
}

head(as.data.frame(df[c("Zuzanna","Julia")]), 100)
DataExplorer::plot_bar(df$Gabriela)

df2 <- df[, !duplicated_col]
DataExplorer::plot_correlation(df2)
which(df$Pola != df$Aleksandra)

hist(df$Lena)
DataExplorer::plot_histogram(df)
(sum(df$Amelia == 0))/nrow(df)
(sum(df$Antonina == 0))/nrow(df)
  
(sum(df$Antonina == df$Amelia & df$Antonina == 0))/sum(df$Amelia == 0 | df$Antonina == 0)
(sum(df$Antonina == df$Amelia & df$Antonina == 0 & df$Emilia == df$Amelia))/sum(df$Amelia == 0 | df$Antonina == 0 | df$Emilia == 0)

rt <- apply(df, 2, function(x){
  which(x == 0)
} )

head(rt$Antonina)
head(rt$Amelia)
which(rt$Amelia != rt$Antonina)

hist(log10(df$Emilia))

dplyr::union(rt)
x<-rt[[4]]
for (i in c('Zofia',"Wiktoria")) {
  x<-union(x,rt[[i]])
}

temp<-df[rt$Amelia,]

DataExplorer::plot_correlation(temp)



#DataExplorer::create_report(d_tr[-1,])




