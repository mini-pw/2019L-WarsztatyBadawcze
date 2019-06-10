require(mlr)
require(dplyr)

dl_duplicated_col <- function(d_tr, d_tt){
  duplicated_col <- logical(ncol(d_tr))
  for(i in 1:ncol(d_tr)){
    for(j in i:ncol(d_tr)){
      if(all(d_tr[ , i] == d_tr[ , j]) & i != j){
       duplicated_col[j] <- TRUE
      }
    }
  }
  d_tr <- d_tr[!duplicated_col]
  d_tt <- d_tt[names(d_tr)]
  rt <- list("tr" = d_tr, "tt" = d_tt)
  rt
}

#uwaga zalozenie o nazwach kolumn
log_trans <- function(df){
  df$Emilia_0 <- df$Emilia == 0
  df$Emilia <- log10(df$Emilia)
  df$Emilia[df$Emilia_0] <- -1
  df
}

#uwaga zalozenie o nazwach kolumn
fact_trans <- function(df){
  df$Anna <- factor(df$Anna, levels = 0:8)
  df<-as_tibble(createDummyFeatures(df))
  df
}


###------------------------------------------------
### COMPUTE DATASET STATISTICS ###
#uwaga zalozenie o wywolaniu przed one-hot enc
cr_stats <- function(df){
  #numberOfCategoricalFeatures
  number_of_categorical <- 0
  number_of_numerical <- 0
  unique_numerical <- 0
  unique_categorical <- 0
  mean_number_missing <- 0
  number_of_instances <- nrow(df)
  
  for(i in 1:ncol(df)){
    # print(i)
    # print(df[1, i])
    if(is.factor(df[[1, i]]) | is.logical(df[[1, i]])){
      #print("factor")
      number_of_categorical <- number_of_categorical + 1
      unique_categorical <- unique_categorical + length(unique(df[[i]]))
    }
    else{
      #print("numerical")
      number_of_numerical <- number_of_numerical + 1
      unique_numerical <- unique_numerical + length(unique(df[[i]]))
    }
  }
  mean_unique_categorical_values <- unique_categorical / number_of_categorical
  mean_unique_numerical_values <- unique_numerical / number_of_numerical
  
  c(number_of_categorical,number_of_numerical, mean_unique_numerical_values,
    mean_unique_categorical_values,mean_number_missing,number_of_instances)
}

all_to_numeric <- function(df){
  for(i in 2:ncol(df)){
    if(is.logical(df[[1, i]]))
      df[[i]] <- as.numeric(df[[i]])
  }
  df
}
