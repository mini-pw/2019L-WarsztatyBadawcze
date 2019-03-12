#:# libraries
from sklearn.preprocessing import Imputer, StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.metrics import roc_curve, classification_report, confusion_matrix, roc_auc_score
from matplotlib import pyplot as plt
from platform import python_version

import openml
import pandas as pd
import numpy as np
import hashlib
import pkg_resources
import datetime
import json

#:# config

np.random.seed(42)

#:# data

datasetId = 853

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

X = df.drop('binaryClass', axis=1)
y = df.loc[:, 'binaryClass']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=42, stratify=y)

#:# preprocessing


#:# model

classifier = LogisticRegression()

classifier.fit(X_train, y_train)

#:# hash
#:# e37d46e1a5c0065376d1471f564f3ac7
md5 = hashlib.md5(str(classifier).encode('utf-8')).hexdigest()
print(f'md5: {md5}')

#:# audit
y_pred = classifier.predict(X_test)
y_pred_proba = classifier.predict_proba(X_test)[:,1]

print(f'Accuracy: {classifier.score(X_test, y_test)}')
print(f'Area under ROC: {roc_auc_score(y_test, y_pred_proba)}')

#:# session info

# Dodaj wersję pythona w session info

sessionInfo = {
    "python_version": python_version(),
    "library_versions":[str(d) for d in pkg_resources.working_set]
}
with open('sessionInfo.txt', 'w') as f:
    json.dump(sessionInfo, f, indent=4)