library(mlr)

set.seed(1)

# Discrete set of hyperparameters
discrete_ps = makeParamSet(
  makeDiscreteParam("C", values = c(0.5, 1.0, 1.5, 2.0)),
  makeDiscreteParam("sigma", values = c(0.5, 1.0, 1.5, 2.0))
)
print(discrete_ps)

# 5-fold CV
rdesc = makeResampleDesc("CV", iters = 5L)
# Create Tune Grid, use all combinations of parameters
ctrl = makeTuneControlGrid()
res = tuneParams("classif.ksvm", task = iris.task, resampling = rdesc,
                 par.set = discrete_ps, control = ctrl)


# Create a search space for the C hyperparameter from 0.01 to 0.1 and sigma hyperparameter from 0.5 to 2.0
ps = makeParamSet(
  makeNumericParam("C", lower = 0.01, upper = 0.1),
  makeNumericParam("sigma", lower = 0.5, upper = 2.0)
)

# grid search search with resolution 15
ctrl = makeTuneControlGrid(resolution = 15L)
res = tuneParams("classif.ksvm", task = iris.task, resampling = rdesc,
                 par.set = ps, control = ctrl)

# random search with 100 iterations
ctrl = makeTuneControlRandom(maxit = 100L)
res = tuneParams("classif.ksvm", task = iris.task, resampling = rdesc,
                 par.set = ps, control = ctrl)

