#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = TRUE)

if (length(args) != 4) {
  message("Invalid arguments. There should be:  Rscript --vanilla main.R train_filename.csv test_filename.csv. Script will run with defaults.", call.=FALSE)
  train_pathname <- "train.csv"
  test_pathname <- "WarsztatyBadawcze_test.csv"
  java_ram <- "5000m"
  tuning_num_cores <- 3 
} else {
  train_pathname <- args[1]
  test_pathname <- args[2]
  java_ram <- args[3]
  tuning_num_cores <- as.integer(args[4])
}


### SOURCES ------------------------------------------
options(java.parameters = paste0("-Xmx", java_ram))
#parallelMap::parallelStartMulticore(tuning_num_cores)
parallelMap::parallelStartSocket(tuning_num_cores)

source("data_load.R")
source("preprocessing.R")
source("model_selection.R")
source("tuning.R")

### REQUIRED PACKAGES --------------------------------
require(dplyr)
require(mlr)
require(digest)
require(mboost)
require(parallelMap)
set.seed(123, "L'Ecuyer")

### DATA LOAD ----------------------------------------
d_tr <- data_load(train_pathname)
d_tt <- data_load(test_pathname)

### PREPROCESSING -------------------------------------
tmp <- dl_duplicated_col(d_tr, d_tt)
d_tr <- tmp$tr
d_tt <- tmp$tt

d_tr <- correct_duplicated_rows(d_tr)

d_tr <- log_trans(d_tr)
d_tt <- log_trans(d_tt)


#dummy variables on one of the variables
d_tr <- fact_trans(d_tr)
d_tt <- fact_trans(d_tt)



### SEARCH FOR GOOD LEARNERS ---------------------------
models_score_pred <- black_box(d_tr)
models_sacred_by_black_box <- models_score_pred %>% arrange(desc(score)) %>% dplyr::select(model) %>% head(n = 1)
bst_cl <- as.character(unlist(models_sacred_by_black_box))
print(paste0("Best model: ", bst_cl))

#all variables to numeric (to be compatible with all models)
d_tr <- all_to_numeric(d_tr)
d_tt <- all_to_numeric(d_tt)



### FINAL PREDICTION --------------------------------
tsk <- makeClassifTask(id = "first", d_tr, "Y")

if(is.null(def_params[[bst_cl]])){
  lrn <- makeLearner(bst_cl, predict.type = "prob")
} else
  lrn <- makeLearner(bst_cl, predict.type = "prob", par.vals = def_params[[model]])

trn <- train(lrn, tsk)
pred <- predict(trn, newdata = d_tt)
write_csv(x = data.frame("prob" = pred$data$prob.TRUE), path = "result_Saputa_Werner_.csv")
