import openml
import numpy as np
import pandas as pd
import hashlib

from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score

# Loading data

datasetOpenmlId = 841

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

X = df.drop('binaryClass', axis=1)
y = df.loc[:, 'binaryClass']

# model

X_train, X_test, y_train, y_test = train_test_split(X,y, random_state=777)

mdl = MLPClassifier(max_iter = 300)
mdl.fit(X_train,y_train)

# Audit

y_pred = mdl.predict(X_test)

print(str.format("ACC: {0}\nAUC: {1}", np.mean(y_pred == y_test), roc_auc_score(y_test, y_pred)))