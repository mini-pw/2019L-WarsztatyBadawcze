
#:# libraries
from sklearn.linear_model.logistic import LogisticRegression
from sklearn.preprocessing import Imputer, StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, roc_auc_score, f1_score, confusion_matrix
from matplotlib import pyplot as plt
from platform import python_version

import openml
import pandas as pd
import numpy as np
import hashlib
import pkg_resources
import datetime
import json
import os

#:# config

np.random.seed(42)

#:# data

datasetId = 853
task_target = 'binaryClass'

dataset = openml.datasets.get_dataset(datasetId)
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

X = df.drop(task_target, axis=1)
y = df.loc[:, task_target]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

#:# preprocessing

transform_pipeline = Pipeline([
    ('scaler', StandardScaler())
])

X_train = pd.DataFrame(transform_pipeline.fit_transform(X_train), columns=X_train.columns)

#:# model

params = {'C': 0.6, 'solver': 'saga'}

classifier = LogisticRegression(**params)
classifier.fit(X_train, y_train)

#:# hash
#:# 9d5c5a077f19a6753d2d39c0f94135d6
md5 = hashlib.md5(str(classifier).encode('utf-8')).hexdigest()
print(f'md5: {md5}')

#:# audit
y_pred = classifier.predict(transform_pipeline.transform(X_test))
y_pred_proba = classifier.predict_proba(transform_pipeline.transform(X_test))[:,1]

tn, fp, fn, tp = confusion_matrix(y_test, y_pred).ravel()

print(f'acc: {accuracy_score(y_test, y_pred)}')
print(f'auc: {roc_auc_score(y_test, y_pred_proba)}')
print(f'precision: {precision_score(y_test, y_pred)}')
print(f'recall: {recall_score(y_test, y_pred)}')
print(f'specificity: {tn/(tn+fp)}')
print(f'f1: {f1_score(y_test, y_pred)}')

#:# session info

# Dodaj wersję pythona w session info

sessionInfo = {
    "python_version": python_version(),
    "library_versions":[str(d) for d in pkg_resources.working_set]
}
with open('sessionInfo.txt', 'w') as f:
    json.dump(sessionInfo, f, indent=4)
    