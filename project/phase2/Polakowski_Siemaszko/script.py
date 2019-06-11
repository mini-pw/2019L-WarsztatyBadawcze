# Dependencies
import pandas as pd
import numpy as np
import pickle
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.ensemble import GradientBoostingClassifier, AdaBoostClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score, accuracy_score
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

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
        return X.drop(self.columns, axis=1)
    

model_map = {
    "svm1": SVC(C=1, gamma=0.1, probability=True, random_state=42),
    "svm2": SVC(C=10, gamma=0.4, probability=True, random_state=42),
    "svm3": SVC(C=100, gamma=1, probability=True, random_state=42),
    "svm4": SVC(C=500, gamma=4, probability=True, random_state=42),
    "svm5": SVC(C=1, gamma=4, probability=True, random_state=42),
    "svm6": SVC(C=10, gamma=1, probability=True, random_state=42),
    "svm7": SVC(C=100, gamma=0.4, probability=True, random_state=42),
    "svm8": SVC(C=500, gamma=0.1, probability=True, random_state=42),
    "dt1": DecisionTreeClassifier(max_depth=2, random_state=42),
    "dt2": DecisionTreeClassifier(max_depth=4, random_state=42),
    "dt3": DecisionTreeClassifier(max_depth=6, random_state=42),
    "dt4": DecisionTreeClassifier(max_depth=10, random_state=42),
    "dt5": DecisionTreeClassifier(max_depth=16, random_state=42),
    "gbc1": GradientBoostingClassifier(n_estimators=40, random_state=42),
    "gbc2": GradientBoostingClassifier(n_estimators=100, random_state=42),
    "gbc3": GradientBoostingClassifier(n_estimators=400, random_state=42),
    "abc1": AdaBoostClassifier(n_estimators=50, random_state=42),
    "abc2": AdaBoostClassifier(n_estimators=100, random_state=42),
    "abc3": AdaBoostClassifier(n_estimators=200, random_state=42),
    "logreg1": LogisticRegression(penalty='l2', solver='liblinear', random_state=42),
    "logreg2": LogisticRegression(penalty='l1', solver='liblinear', random_state=42),
    "logreg3": LogisticRegression(penalty='l2', solver='liblinear', C=0.5, random_state=42),
    "logreg4": LogisticRegression(penalty='l1', solver='liblinear', C=0.5, random_state=42),
    "nn1": MLPClassifier((100,),alpha=0.0001, random_state=42),
    "nn2": MLPClassifier((100,200,100),alpha=0.001, random_state=42),
    "nn3": MLPClassifier((100,200,200,100),alpha=0.001, random_state=42),
    "nn4": MLPClassifier((100,100,),alpha=0.0001, random_state=42)
}

def transform_dataset(X, y):
    X = StandardScaler().fit_transform(X)
    n = X.shape[0]
    selector = np.random.choice(np.arange(n),size=np.min([2500,n]), replace=False)
    return X[selector,:], y[selector]

def transform_dataset_to_model_response_vector(X, y, models):
    keys = models.keys()
    X_model_layer, X_regr_layer, y_model_layer, y_regr_layer = train_test_split(X, y, test_size=0.6, random_state=42)
    X_model_layer, X_regr_layer, y_model_layer, y_regr_layer = train_test_split(X, y, test_size=0.6, random_state=42)
    X_regr_train_layer, X_regr_test_layer, y_regr_train_layer, y_regr_test_layer = train_test_split(X_regr_layer, y_regr_layer, test_size=1/3, random_state=42)
    X_regr_train_layer, X_regr_test_layer, y_regr_train_layer, y_regr_test_layer = train_test_split(X_regr_layer, y_regr_layer, test_size=1/3, random_state=42)
    predict_proba_train_map = {}
    predict_proba_test_map = {}
    for i, (key, model) in enumerate(models.items()):
        model.fit(X_model_layer,y_model_layer)
        predict_proba_train_map[key] = model.predict_proba(X_regr_train_layer)[:,1]
        predict_proba_test_map[key] = model.predict_proba(X_regr_test_layer)[:,1]
        print(f'fitted {i+1}/{len(models)} models (last fitted: {key})', end = "\r" , flush=True)
    print()
    predict_proba_train_dataset = pd.DataFrame(predict_proba_train_map)
    predict_proba_test_dataset = pd.DataFrame(predict_proba_test_map)
    logreg = LogisticRegression(penalty='l2',fit_intercept=False, solver='liblinear')
    logreg.fit(predict_proba_train_dataset, y_regr_train_layer)
    print(f'Accuracy: {logreg.score(predict_proba_test_dataset, y_regr_test_layer)}')
    print(f'AUC: {roc_auc_score(y_regr_test_layer, logreg.predict_proba(predict_proba_test_dataset)[:,1])}')
    return pd.Series(data = logreg.coef_[0], index = keys)


# Data loading
train = pd.read_csv("train.csv", sep=';')
test = pd.read_csv("WarsztatyBadawcze_test.csv", sep=';')
response_vectors_df = pd.read_csv("response_vectors.csv",index_col=0)
# Make sure that dataset model map keys are strings
with open('dataset_model_map','br') as f:
    dataset_model_map = pickle.load(f)

pipeline = make_pipeline(DropTransformer(columns=['Aleksandra','Gabriela','Julia','Maria','Nikola','Oliwia','Pola']), StandardScaler(with_mean=False))

# Model magic
X_train, y_train = train.drop('Y',axis=1), train.Y
X_test = test.drop('Y',axis=1)

X_train = pipeline.fit_transform(X_train)
X_test = pipeline.transform(X_test)

# Map dataset to model response vectorspace
X_for_response_vector, y_for_response_vector = transform_dataset(X_train, y_train)

response_vector = transform_dataset_to_model_response_vector(X_for_response_vector, y_for_response_vector, model_map)

# Find closest pre-analyzed dataset
most_similar_dataset_id = str(response_vectors_df.apply(lambda x: cosine_similarity(x.values.reshape(1,-1),response_vector.values.reshape(1,-1))[0][0],axis=1).idxmax())

# Choose and train model
model = dataset_model_map[most_similar_dataset_id]
model.fit(X_train, y_train)

# Return probabilities
y_pred_proba = pd.DataFrame({'Y':model.predict_proba(X_test)[:,1]})

# Output saving
y_pred_proba.to_csv("test_probabilities.csv", sep=';')
