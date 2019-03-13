library(jsonlite)
library(data.table)

# funkcja do tworzenia listy cat_frequencies
returnif <- function(elem,list){
  if(is.numeric(elem)){
    r <- NA
  }else{
    r <- as.list(table(list))
  }
  r
}

#funkcja do tworzenia pliku JSON
createJSON <- function(filename){
  #tu można podać dodatkowe parametry wczytywania pliku
  data <- fread(filename,data.table = FALSE)
  
  
  
  b <- lapply(1:ncol(data), function(n) {
    
    ind <- is.numeric(data[1,n])
    list(name=colnames(data)[n],
         type=ifelse(ind,"numerical","categorical"),
         number_of_unique_values=length(unique(data[,n])),
         number_of_missing_values=sum(is.na(data[,n])),
         cat_frequencies=returnif(data[1,n],data[,n]),
         num_minimum=ifelse(ind,min(data[,n]),NA),
         num_1qu=ifelse(ind,quantile(data[,n])[2],NA),
         num_median=ifelse(ind,median(data[,n]),NA),
         num_mean=ifelse(ind,mean(data[,n]),NA),
         num_3qu=ifelse(ind,quantile(data[,n])[4],NA),
         num_maximum= ifelse(ind,max(data[,n]),NA))
    })
  
  names(b) <- colnames(data)
  
  #tu należy podać dane swojego pliku (id, added_by, name, source, url )
  dataset <- list(list(id="", 
                       added_by="",
                       date=format(Sys.time(), "%d-%m-%Y"),
                       name="",
                       source="",
                       url="",
                       number_of_features = ncol(data),
                       number_of_instances= nrow(data),
                       number_of_missing_values= sum(is.na(data)),
                       number_of_instances_with_missing_values= sum(rowSums(is.na(data))!=0),
                       variables=b))
  
  file1 <- toJSON(dataset, pretty = TRUE,auto_unbox = TRUE)
  
  write(file1, "dataset.json")
  
}

createJSON("PopularKids.csv")
