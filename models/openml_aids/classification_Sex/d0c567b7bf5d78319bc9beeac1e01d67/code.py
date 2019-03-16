#:# libraries
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.metrics import f1_score, accuracy_score, precision_score, recall_score, roc_auc_score
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

datasetOpenmlId = 346

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

X = df.drop('Sex', axis=1)
y = df.loc[:, 'Sex']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, stratify=y)
#:# preprocessing


#:# model

classifier = RandomForestClassifier(n_estimators=500, max_depth=2, max_features=3)

classifier.fit(X_train, y_train)

#:# hash
#:# d0c567b7bf5d78319bc9beeac1e01d67
md5 = hashlib.md5(str(classifier).encode('utf-8')).hexdigest()
print(f'md5: {md5}')

#:# audit
y_pred = classifier.predict(X_test)
y_pred_proba = classifier.predict_proba(X_test)[:,1]

print(f'Accuracy: {accuracy_score(y_test, y_pred)}')
print(f'Area under ROC: {roc_auc_score(y_test, y_pred_proba)}')
print(f'Precision: {precision_score(y_test, y_pred)}')
print(f'Recall: {recall_score(y_test, y_pred)}')
print(f'F1 score: {f1_score(y_test, y_pred)}')

#:# session info

# Dodaj wersję pythona w session info - DONE

sessionInfo = {
    "python_version": python_version(),
    "library_versions":[str(d) for d in pkg_resources.working_set]
}
with open('sessionInfo.txt', 'w') as f:
    json.dump(sessionInfo, f, indent=4)
