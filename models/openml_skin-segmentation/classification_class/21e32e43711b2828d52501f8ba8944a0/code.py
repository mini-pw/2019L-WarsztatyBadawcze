#:# libraries
from sklearn.ensemble import RandomForestClassifier
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
datasetOpenmlId = 1502
dataset = openml.datasets.get_dataset(datasetOpenmlId)
X, y, categorical, names = dataset.get_data(
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

X = df.drop('Class', axis=1)
y = df.loc[:, 'Class']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=420)

#:# preprocessing

#:# model
model = RandomForestClassifier(n_estimators=100, max_depth=7)
model.fit(X_train, y_train)

#:# hash
#:# e37d46e1a5c0065376d1471f564f3ac7
md5 = hashlib.md5(str(model).encode('utf-8')).hexdigest()
print(f'md5: {md5}')

#:# audit
y_pred = model.predict(X_test)
y_pred_proba = model.predict_proba(X_test)[:, 1]
print(f'Accuracy: {model.score(X_test, y_test)}')
print(f'Area under ROC: {roc_auc_score(y_test, y_pred_proba)}')

#:# session info
sessionInfo = {
    "python_version": python_version(),
    "library_versions":[str(d) for d in pkg_resources.working_set]
}
with open('sessionInfo.txt', 'w') as f:
    json.dump(sessionInfo, f, indent=4)
