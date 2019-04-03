# libraries
library(digest)
library(OpenML)
library(parsnip)

# data
liver_disorders <- getOMLDataSet(data.id = 8L)
liver <- liver_disorders$data
head(liver)

# train test split
n <- nrow(liver)
train_index <- sample(1:n, 0.8 * n)

train <- liver[train_index, ]
test <- liver[-train_index, ]

# model + engine + args
model <- rand_forest(mode = "regression") %>%  
  set_engine("ranger", seed = 63233) %>%
  set_args(trees = 2000, mtry = 4) %>%
  fit(drinks~., data = liver)
# List of models
# https://tidymodels.github.io/parsnip/articles/articles/Models.html

# prediction
predict(model, test)


