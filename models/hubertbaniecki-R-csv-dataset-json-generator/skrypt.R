library(gdata)
library(jsonlite)
library(readr)
options(stringsAsFactors = FALSE)

categoricalColumnToList <- function(column, name) {
  freq <- table(column)
  catFrequenciesList <- as.list(as.integer(freq))
  names(catFrequenciesList) <- names(freq)
  
  ret <- list("name" = name,
                 "type" = "categorical",
                 "number_of_unique_values" = length(unique(rownames(table(column)))),
                 "number_of_missing_values" = sum(is.na(column)),
                 "cat_frequencies" = catFrequenciesList,
                 "num_minimum" = "null",
                 "num_1qu" = "null",
                 "num_median" = "null",
                 "num_mean" = "null",
                 "num_3qu" = "null",
                 "num_maximum" = "null")
  ret
}

numericalColumnToList <- function(column, name) {
  quantiles <- quantile(column, na.rm=TRUE)
  
  ret <- list("name" = name,
                 "type" = "numerical",
                 "number_of_unique_values" = length(unique(rownames(table(column)))),
                 "number_of_missing_values" = sum(is.na(column)),
                 "cat_frequencies" = "null",
                 "num_minimum" = quantiles[[1]],
                 "num_1qu" = quantiles[[2]],
                 "num_median" = quantiles[[3]],
                 "num_mean" = mean(column, na.rm=TRUE),
                 "num_3qu" = quantiles[[4]],
                 "num_maximum" = quantiles[[5]])
  ret
}

makeList <- function(dane, types) {
  variablesList <- list()
  
  for(i in 1:dim(dane)[2]){
    variableName <- colnames(dane)[i]
    column <- dane[,i]
    
    #if(types[i] == "n")
    if(is.numeric(column)){ 
      variablesList[[variableName]] <- numericalColumnToList(as.numeric(as.character(column)), variableName)
    } else {
      variablesList[[variableName]] <- categoricalColumnToList(as.character(column), variableName)
    }
  }
  #paste(from,"_",strsplit(fileName, "\\.")[[1]][1],sep="") - id z nazwy pliku
  
  ret <- list(
    "id" = paste(from, "_", someId, sep=""),
    "added_by" = "hubertbaniecki",
    "date" = format(Sys.Date(), format="%d-%m-%Y"),
    "name" = someName,
    "source" = from,
    "url" = URL,
    "number_of_features" = dim(dane)[2],
    "number_of_instances" = dim(dane)[1],
    "number_of_missing_values" = sum(is.na(dane)),
    "number_of_instances_with_missing_values" = dim(dane)[1]-sum(complete.cases(dane)),
    "variables" = variablesList
  )
  ret
}

          ##########################################################
          # NORMALNY, FAJNY, PRZYJAZNY DOBREMU CZŁOWIEKOWI DATASET #
          ##########################################################

# argumenty
fileName <- "master.csv"            # jeżeli plik jest w folderze projektu
separator <- ","                    # ; " " ""          itp.
missing <- ""                       # "Unknown" "?" ""  itp.
from <- "kaggle"                    # openml            itp.
URL <- "https://www.kaggle.com/russellyates88/suicide-rates-overview-1985-to-2016"
someId <- "suicide-rates-overview-1985-to-2016"
someName <- "Suicide Rates Overview 1985 to 2016"

# gdy chcemy ustalić swoje typy kolejnych kolumn (zmień linijka 49)
# jeżeli ufamy sensowności datasetu i R to można się obyć bez tego
#types <- c("c","n","c","c","n","c")

enc <- guess_encoding(fileName, n_max = 10000)[[1]]
dane <- as.data.frame(read_csv(fileName, locale = locale(encoding = enc[1])))
dane <- unknownToNA(dane, missing)

# usunięcie kolumny z ID (u mnie produkuje zmienną kategoryczną z 10k unikalnych wartości)
# dane <- dane[,-1]

          ####################################
          # STWORZENIE JSON I ZAPIS DO PLIKU #
          ####################################

x <- makeList(dane, types)
y <- jsonlite::toJSON(x, pretty = TRUE, auto_unbox = TRUE)
write(y, "dataset.json")

