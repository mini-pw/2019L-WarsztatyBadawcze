library(readr)
library(mlr)
library(ggplot2)

readr::read_csv("final_dataset.csv", col_types = cols(
  library = col_factor(),
  model_name = col_factor(),
  numberOfCategoricalFeatures = col_double(),
  numberOfNumericalFeatures = col_double(),
  meanUniqueNumericalValues = col_double(),
  meanUniqueCategoricalValues = col_double(),
  meanNumberMissing = col_double(),
  number_of_instances = col_double(),
  ACC = col_double()
)) -> df

df <- df[!is.na(df$meanUniqueNumericalValues), ] 
df <- df[!is.na(df$meanUniqueCategoricalValues), ] 


### 1 ###
set.seed(1)
regr_task = makeRegrTask(id = "task", data = df, target = "ACC")
regr_lrn = makeLearner("regr.gbm", par.vals = list(n.trees = 500, interaction.depth = 3))

cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
r$aggr
### result ###
# Aggregated Result: mse.test.mean=0.0032325,rmse.test.rmse=0.0568548,mae.test.mean=0.0311541,rsq.test.mean=0.7358839

### 2 ###
set.seed(1)
regr_task = makeRegrTask(id = "task", data = df, target = "ACC")
regr_lrn = makeLearner("regr.bartMachine")

cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
r$aggr
### result ###
# Aggregated Result: mse.test.mean=0.0016731,rmse.test.rmse=0.0409037,mae.test.mean=0.0252164,rsq.test.mean=0.8596590

### 3 ###
set.seed(1)
regr_task = makeRegrTask(id = "task", data = df, target = "ACC")
regr_lrn = makeLearner("regr.randomForest")

cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
r$aggr
### result ###
# Aggregated Result: mse.test.mean=0.0021987,rmse.test.rmse=0.0468899,mae.test.mean=0.0298032,rsq.test.mean=0.8193753


