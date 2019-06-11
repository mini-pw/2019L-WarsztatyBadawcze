# Dependencies
import pandas as pd
import numpy as np
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

# Prerequisities
def get_intervals_for_variable(series, n=10, missing_values_indicators = [0]):
    series_copy = series.copy()
    binary_dictionary = {}
    ticks = sorted(missing_values_indicators)
    for i in range(1, n):
        ticks.append(int(series.loc[np.logical_not(series.isin(missing_values_indicators))].quantile(i/n)))
    ticks=np.unique(ticks)
    intervals = [pd.Interval(ticks[i], ticks[i+1],closed='left') for i in range(len(ticks)-1)]
    intervals.append(pd.Interval(ticks[-1],np.inf,closed='left'))
    return pd.IntervalIndex(intervals)

def transform_input_for_submodel(X, variables, variables_intervals):
    converted_series_list = []
    for variable in variables:
        series = X.loc[:,variable].reset_index(drop=True)
        converted_series = pd.get_dummies(pd.cut(series,variables_intervals[variable]))
        converted_series.columns = pd.Series(converted_series.columns).apply(lambda x : f"{variable} - {x}")
        converted_series_list.append(converted_series)
    return pd.concat(converted_series_list, axis=1, ignore_index=True)

def create_submodel(X, y, variables, variables_intervals):
    transformed_X = transform_input_for_submodel(X, variables, variables_intervals)
    model = LogisticRegression(penalty='l1',solver='liblinear',C=0.5)
    model.fit(transformed_X,y)
    return model

def submodels_predict(X, submodels, submodel_dictionary, variables_intervals):
    return { group: submodels[group].predict_proba(transform_input_for_submodel(X, variables, variables_intervals))[:,1] for group, variables in submodel_dictionary.items()}

# Data loading
train = pd.read_csv("train.csv", sep=';')
test = pd.read_csv("WarsztatyBadawcze_test.csv", sep=';')

# Transform pipeline
class DropTransformer(BaseEstimator, TransformerMixin):
    """
    Transformer to map selected variables to log
    """
    def __init__(self, columns):
        self.columns = columns

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        return X.drop(columns, axis=1)

pipeline = make_pipeline(DropTransformer(columns=['Aleksandra','Gabriela','Julia','Maria','Nikola','Oliwia','Pola']), StandardScaler(with_mean=False))

# Model magic
X_train, y_train = train.drop('Y',axis=1), train.Y
X_test = test.drop('Y',axis=1)

X_train = pipeline.fit_transform(X_train)
X_test = pipeline.transform(X_test)

submodel_dictionary = {f'feature_subset_{i+1}': np.random.choice(X_train.columns, size = int(len(X_train.columns)/4), replace = False) for i in range(30)}
variables_intervals = {variable: get_intervals_for_variable(X_train.loc[:,variable]) for variable in X_train.columns}
{group: create_submodel(X_train, y_train, variables, variables_intervals) for group, variables in submodel_dictionary.items()}
submodels = {group: create_submodel(X_train, y_train, variables, variables_intervals) for group, variables in submodel_dictionary.items()}
model = LogisticRegression(C=1, solver='liblinear', penalty='l1')
model.fit(pd.DataFrame(submodels_predict(X_train, submodels, submodel_dictionary, variables_intervals)), y_train)
y_pred_proba = pd.DataFrame({'Y':model.predict_proba(pd.DataFrame(submodels_predict(X_test, submodels, submodel_dictionary, variables_intervals)))[:,1]})

# Output saving
y_pred_proba.to_csv("test_probabilities.csv", sep=';')