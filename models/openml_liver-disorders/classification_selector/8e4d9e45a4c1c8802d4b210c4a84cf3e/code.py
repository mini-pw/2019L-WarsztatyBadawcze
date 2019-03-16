#:# libraries
from sklearn.ensemble import GradientBoostingClassifier, RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score, f1_score
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

datasetOpenmlId = 8

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

names.append(dataset.default_target_attribute)
names.pop(-2)

X = df.drop('selector', axis=1)
y = df.loc[:, 'selector']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=42)

#:# preprocessing


#:# model

classifier = RandomForestClassifier(verbose=True, random_state=42, n_estimators=2000, max_features=4, max_depth=6, n_jobs = 3)

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

sessionInfo = {
    "python_version": python_version(),
    "library_versions":[str(d) for d in pkg_resources.working_set]
}
with open('sessionInfo.txt', 'w') as f:
    json.dump(sessionInfo, f, indent=4)
