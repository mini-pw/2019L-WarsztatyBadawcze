library(mlr)
library(reader)
library(dplyr)
library(DataExplorer)
library(tidyr)

setwd("C:/Users/Piotr/Documents/GitHub/2019L-WarsztatyBadawcze/models")
getwd()
list.files()

library("rjson")

getModelDetails <- function(modelFolder) {

  # "kaggle_heart-disease/classification_sex/8da9a1cc0f5ecfa8729f7412a93d05cc"
  
  # audit
  audit <- fromJSON(file = paste(modelFolder, "audit.json", sep='/'))[[1]]
  
  # model
  model <- fromJSON(file = paste(modelFolder, "model.json", sep='/'))[[1]]
  
  for(variableName in attributes(model$preprocessing)$names) {
    types[variableName] <- model$preprocessing[[variableName]]$type
  }
  
  tab <- table(types)
  
  # -
  data.frame(categorical = unname(ifelse(is.na(tab['categorical']), 0, tab['categorical'])),
    numerical = unname(ifelse(tab['numerical'] %>% is.na, 0, tab['numerical'])),
    library = model$library,
    classifier = model$model_name,
    acc = audit$performance$acc)
  # -
}

getModelDetails("./openml_dermatology/classification_class/9ddf48ef73d740970fabd13a48745ee4")


getDataset <- function(dataFolder) {
  # dataset
  dataset <- fromJSON(file = paste(dataFolder, "dataset.json", sep = '/'))[[1]]
  
  # Utworzenie tabeli rows
  rows <- data.frame(dataset_id = character(),
                     number_of_features = integer(),
                     number_of_instances = integer(),
                     categorical = integer(),
                     numerical = integer(),
                     library = character(),
                     classifier = character(),
                     acc = numeric())
  
  # Początek pierwszej iteracji : po folderach klasyfikacji
  listOfDirs <-  list.dirs(dataFolder, recursive = FALSE)
  indexes <- grep("class+", listOfDirs)
  
  if(length(indexes) == 0) {return}
  
  for(dir in listOfDirs[indexes]) {
    
    # Początek drugiej iteracji : po folderach modeli
    listOfModelDirs <- list.dirs(
      dir,
      recursive = FALSE
    )
    
    if(length(listOfModelDirs) == 0) {
      break
    }
    
    for(modelFolder in listOfModelDirs){
      r <- cbind(dataset_id = dataset$id,
             number_of_features = dataset$number_of_features %>% as.integer(),
             number_of_instances = dataset$number_of_instances %>% as.integer(),
             getModelDetails(modelFolder))
      rows <- rbind(rows, r)
    }
  }
  rows
}

getModelDetails("kaggle_heart-disease/classification_sex/8da9a1cc0f5ecfa8729f7412a93d05cc")



OstatecznyDataset <- data.frame(dataset_id = character(),
                   number_of_features = integer(),
                   number_of_instances = integer(),
                   categorical = integer(),
                   numerical = integer(),
                   library = character(),
                   classifier = character(),
                   acc = numeric())

AllDatasets <- list.dirs(recursive = FALSE)

AllDatasets <- AllDatasets[!(AllDatasets %in% c("./openml_lowbwt",
                                                "./openml_dermatology",
                                                "./openml_mnist_rotation"))]

for(dataset in AllDatasets) {
  print(dataset)
  OstatecznyDataset <- rbind(OstatecznyDataset, getDataset(dataset)) 
}

setwd("~/Bogdan/Warsztaty badawcze/Projekt")
# save(OstatecznyDataset, file = "OstatecznyDataset.rda")

# Drobna analizka

library(DataExplorer)

create_report(OstatecznyDataset)

##################### Klasyfikacja #####################
library(mlr)

# Przygotowanie danych
data_prev <- OstatecznyDataset %>% drop_columns(c("dataset_id",
                                           "library"))
tab <- table(data_prev$classifier) %>% sort()
data <- data_prev[data_prev$classifier %in% names(tab[tab>25]),]

data$classifier <- data$classifier %>% droplevels()

# Podział zbioru
set.seed(12)
index <- sample(1:nrow(data), nrow(data)/10)

train <- data[-index,]
test <- data[index, ]

length(unique(train$classifier))
length(unique(data$classifier))

# Task

task <- makeRegrTask(id = "learn", data = train, target = "acc")

# Regressor

learner <- makeLearner("regr.bartMachine")

# Model

model <- train(learner, task)

# Train validation

prediction <- predict(model, newdata = test)

performance(prediction) # SUPER!!!


# Moja ramka 

# 23 kolumny
# 4184 wiersze
# 13 kategorycznych
# 10 numerycznych

moje <- data.frame(number_of_features = 23,
                   number_of_instances = 4184,
                   categorical = 13,
                   numerical = 10,
                   classifier = "")

classifiers <- unique(train$classifier)

accTable <- data.frame(classifier = character(),
                       ACC = numeric(),
                       Mean = numeric())

for(clas in classifiers) {
  moje$classifier <- clas
  accTable <- rbind(accTable, data.frame(
    classifier = clas,
    ACC = predict(model, newdata = moje)$data$response,
    Mean = mean(train[train$classifier == clas,"acc"])
  ))
}

tabela_wynikow <- accTable %>%
  mutate(sub = ACC - Mean) %>% 
  arrange(ACC)

save(tabela_wynikow, file = "wynikiKlasyfikacji.rda")
