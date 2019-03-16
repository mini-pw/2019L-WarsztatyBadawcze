#:# libraries
library(digest)
library(mlr)

source("generate_audit_model_task_json_hubertbaniecki_v2.R"); 

make3JSON('WojciechKretowicz','kaggle_MPI_national','regression', regr_task, regr_lrn, c('MSE','RMSE','MAE','RSQ'))

#:# config
set.seed(123, "L'Ecuyer")



#:# data
df <- read.csv("MPI_national.csv")

#:# preprocessing
df <- df[,3:8]


#:# model

regr_task <- makeRegrTask(data=df, target = 'MPI.Rural')

discrete_ps = makeParamSet(
  makeDiscreteParam("gamma", values = rep(10,5) ^ seq(-2,2)),
  makeDiscreteParam('kernel', values = c('linear','radial','polynomial','sigmoid'))
)
ctrl = makeTuneControlGrid()
rdesc = makeResampleDesc("CV", iters = 5L)
res = tuneParams("regr.svm", task = regr_task, resampling = rdesc,
                 par.set = discrete_ps, control = ctrl, measures = list(mse,rmse,mae,rsq))


regr_lrn <- makeLearner('regr.svm', par.vals = list('gamma' = 0.1, 'kernel'='linear'))

#:# hash 
#:# c147040bb9c51e29cb17df401adcd6f4
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse,rmse,mae,rsq))
r$aggr
