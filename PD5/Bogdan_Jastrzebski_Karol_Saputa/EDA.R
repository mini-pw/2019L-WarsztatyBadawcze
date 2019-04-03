setwd("../CaseStudies2019S/models")
library(jsonlite)
library(dplyr)
library(DataExplorer)
library(readr)

### audit.json ###
all_audit_jsons <- list.files(recursive = TRUE, pattern = "audit.json")

audits <- data.frame("model_ID"= NA, "MSE"= NA, "RMSE"=NA, "MAE"=NA,
                                 "R2"= NA, "ACC"=NA, "AUC"=NA,
                                  "SPECIFICITY"= NA, "RECALL"=NA, "PRECISION"=NA,
                                "F1"= NA)
names(audits) <- substr(toupper(names(audits)),start = 1, stop = 3)
for(i in all_audit_jsons){
  audit <- jsonlite::fromJSON(i)
  names(audit$performance) <- substr(toupper(names(audit$performance)),start = 1, stop = 3)
  audit$performance$model_ID <- audit$model_id
  #audit$performance$task_id <- audit$task_id
  audits <- bind_rows(audits, audit$performance)
  
}
regr_metrics <- c("MSE", "RMSE", "MAE",
                  "R2")
View(audits)
View(audits %>% filter(!is.na(RSQ)))
audits %>% filter(is.na(RSQ) & is.na(TNR)) -> audits_filtered
audits_filtered %>% filter(!((is.na(MSE) | is.na(RMS) | is.na(MAE) | is.na(R2)) & is.na(ACC))) -> audits_filtered
audits_filtered %>% filter(!((is.na(AUC) | is.na(ACC) | is.na(SPE) | is.na(REC) | is.na(PRE) | is.na(F1)) & is.na(MSE))) -> audits_filtered
colnames(audits_filtered)
drop_columns(audits_filtered, c("MOD", "RSQ", "TNR", "TPR", "PPV", "MAQ")) -> audits_filtered
readr::write_csv(audits_filtered, "../../PD5/df_clear_all.csv")
audits_filtered %>% select(ACC, model_ID) %>% filter(!is.na(ACC)) -> audits_acc
readr::write_csv(audits_acc, "../../PD5/df_clear_acc.csv")


### dataset.json ###
all_dataset_jsons <- list.files(recursive = TRUE, pattern = "dataset.json")
dataset_info <- data.frame("number_of_instances" = NA, "id" = NA)

for(i in all_dataset_jsons){
  ds <- jsonlite::fromJSON(i)
  row <- data.frame("number_of_instances" = NA, "id" = NA)
  row$number_of_instances <- ds$number_of_instances
  row$id <- ds$id

   dataset_info <- bind_rows(dataset_info, row)
  
}
dataset_info <- dataset_info[-1, ]
readr::write_csv(dataset_info, "../../PD5/df_dataset_info.csv")


### model.json ###
all_model_jsons <- list.files(recursive = TRUE, pattern = "model.json")



models <- data.frame()

for(i in all_model_jsons){
  model <- jsonlite::fromJSON(i)
  # print(i)
  # index <- index + 1
  # print(index)
  row <- data.frame("id" = NA,
                    "library" = NA,
                    "model_name" = NA,
                    "numberOfCategoricalFeatures" = NA,
                    "numberOfNumericalFeatures" = NA,
                    "meanUniqueNumericalValues" = NA,
                    "meanUniqueCategoricalValues" = NA,
                    "meanNumberMissing" = NA,
                    "datasetID" = NA)
  
  row$id <- model$id
  row$library <- model$library
  row$model_name <- model$model_name
  row$datasetID <- model$dataset_id
  
  row$numberOfCategoricalFeatures <- 0
  row$numberOfNumericalFeatures <- 0
  
  row$meanUniqueNumericalValues <- 0
  row$meanUniqueCategoricalValues <- 0
  
  row$meanNumberMissing <- 0
  
  for(f in model$preprocessing) {
    if(f$type == "numerical") {
      row$numberOfNumericalFeatures <- row$numberOfNumericalFeatures+1
      row$meanUniqueNumericalValues <- row$meanUniqueNumericalValues + f$number_of_unique_values
    } else {
      row$numberOfCategoricalFeatures <- row$numberOfCategoricalFeatures+1
      row$meanUniqueCategoricalValues <- row$meanUniqueCategoricalValues + f$number_of_unique_values
    }
    row$meanNumberMissing <- row$meanNumberMissing + f$number_of_missing_values
  }
  
  row$meanUniqueNumericalValues <- row$meanUniqueNumericalValues / row$numberOfNumericalFeatures
  row$meanUniqueCategoricalValues <- row$meanUniqueCategoricalValues / row$numberOfCategoricalFeatures
  
  models <- bind_rows(models, row)
}

readr::write_csv(models, "models.csv")

### merging data ###
clear_acc <- readr::read_csv("df_clear_acc.csv")
dataset_info <- readr::read_csv("df_dataset_info.csv")
models <- readr::read_csv("models.csv")


models %>%
  left_join(dataset_info, by = c("datasetID" = "id")) %>%
  filter(!is.na(number_of_instances)) %>%
  left_join(clear_acc, by = c("id" = "model_ID")) %>% 
  filter(!is.na(ACC))-> df

colnames(models)
colnames(dataset_info)
colnames(clear_acc)
length(unique(df$id))

table(df$id) %>%  data.frame() %>% filter(Freq == 1) -> h

df %>%
  filter(id %in% h$Var1) %>%
  select(-c("id","datasetID")) -> df

df
write_csv(df, "final_dataset.csv")
df_fin <- readr::read_csv("final_dataset.csv", col_types = cols(
  library = col_factor(),
  model_name = col_factor(),
  numberOfCategoricalFeatures = col_double(),
  numberOfNumericalFeatures = col_double(),
  meanUniqueNumericalValues = col_double(),
  meanUniqueCategoricalValues = col_double(),
  meanNumberMissing = col_double(),
  number_of_instances = col_double(),
  ACC = col_double()
))

### vtreat ###
library(vtreat)
treatplan <- designTreatmentsN(df, varlist = colnames(df), outcomename = "ACC")
ggplot(treatplan$scoreFrame, aes(x = varName, y=rsq)) + geom_col() + coord_flip()

### Data Explorer ###
DataExplorer::plot_boxplot(df[, c("model_name", "ACC")], by = "model_name")
DataExplorer::plot_scatterplot(df[, c("meanUniqueNumericalValues", "ACC")], by = "ACC")
