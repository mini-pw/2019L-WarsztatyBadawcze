import openml
import numpy as np
import pandas as pd
import hashlib

from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

# Loading data

datasetOpenmlId = 300

dataset = openml.datasets.get_dataset(datasetOpenmlId)

(X, y, categorical, names) = dataset.get_data(
    target=dataset.default_target_attribute,
    return_categorical_indicator=True,
    return_attribute_names=True,
    include_ignore_attributes=True
)

vals = {}
for i, name in enumerate(names):
    vals[name] = X[:, i]
vals[dataset.default_target_attribute] = y
df = pd.DataFrame(vals)

X = df.drop('f1', axis=1)
y = df.loc[:, 'f1']

# model

X_train, X_test, y_train, y_test = train_test_split(X,y, random_state=777)

mdl =LinearRegression()
mdl.fit(X_train,y_train)

# Audit

y_pred = mdl.predict(X_test)

print(str.format("MSE: {0}\nRMSE: {1}\nMAE: {2}\nR2: {3}", mean_squared_error(y_test, y_pred),
                 np.sqrt(mean_squared_error(y_test, y_pred)), mean_absolute_error(y_test, y_pred),
                 r2_score(y_test,y_pred)))