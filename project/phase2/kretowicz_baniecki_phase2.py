import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler

train = pd.read_csv('train.csv', sep=';')
test = pd.read_csv('WarsztatyBadawcze_test.csv', sep=';')

train = train.drop(columns=['Aleksandra','Gabriela','Julia','Maria','Nikola','Oliwia',
                            'Pola','Natalia','Zuzanna','Liliana','Nadia'])
test = test.drop(columns=['Aleksandra','Gabriela','Julia','Maria','Nikola','Oliwia',
                          'Pola','Natalia','Zuzanna','Liliana','Nadia','Y'])

testPrzedStd = test.copy()

train.drop_duplicates(inplace=True)

train.Alicja = np.sqrt(np.sqrt(train.Alicja + 1))
train.Amelia = np.sqrt(train.Amelia+1)
train.Antonina = np.sqrt(train.Antonina)
train.Emilia = np.log(train.Emilia + 1)

test.Alicja = np.sqrt(np.sqrt(test.Alicja + 1))
test.Amelia = np.sqrt(test.Amelia+1)
test.Antonina = np.sqrt(test.Antonina)
test.Emilia = np.log(test.Emilia + 1)

trainX = train.drop(columns='Y')
trainY = train.Y

stdsc = StandardScaler()
trainX = stdsc.fit_transform(trainX)

lr = LogisticRegression(C=0.3629140802716761, tol = 0.0005297221489221855, penalty = 'l1') 
# {'tol': 0.0005297221489221855, 'penalty': 'l1', 'C': 0.3629140802716761}
lr.fit(trainX,trainY)

test = stdsc.transform(test)

y_pred = lr.predict_proba(test)
y_pred = y_pred[:,1]
y_pred[testPrzedStd.Zofia < 30] = 1

pd.Series(y_pred).to_csv("testY.csv", sep = ';')