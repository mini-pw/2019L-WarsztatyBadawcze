library(reader)
library(dplyr)
library(DataExplorer)
library(tidyr)

data <- read.csv("final_dataset.csv")

data %>% head

newData <- data %>% select(-library, ACC, -number_of_instances, -numberOfCategoricalFeatures, -meanUniqueCategoricalValues)

mapply(length, uniques) %>% mean -> meanUnique

head(newData)

newData$numberOfNumericalFeatures <- abs(newData$numberOfNumericalFeatures - 14)
newData$meanUniqueNumericalValues <- abs(newData$meanUniqueNumericalValues - meanUnique)

head(newData)

newData %>% 
  group_by(numberOfNumericalFeatures, meanUniqueNumericalValues) %>% 
  arrange(-ACC) %>%
  filter(row_number() == 1) %>% 
  group_by(model_name) %>% 
  summarise(count = n()) %>% 
  arrange(-count)
  
# mam złe dane C;

newData %>%
  group_by(model_name) %>% 
  summarise(mean = mean(ACC), count = n()) %>% 
  filter(count>5) %>% 
  arrange(-mean) 

# z tej analizki wynika, że wezmę rangera

newData %>% 
  filter(numberOfNumericalFeatures < 10) %>% 
  arrange(-ACC) 
  






