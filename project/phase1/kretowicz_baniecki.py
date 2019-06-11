import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler

train = pd.read_csv('train.csv', sep=';')
test = pd.read_csv('WarsztatyBadawcze_test.csv', sep=';')

train = train.drop(columns=['Aleksandra','Gabriela','Julia','Maria','Nikola','Oliwia','Pola','Natalia','Zuzanna','Liliana','Nadia'])
test = test.drop(columns=['Aleksandra','Gabriela','Julia','Maria','Nikola','Oliwia','Pola','Natalia','Zuzanna','Liliana','Nadia','Y'])

trainX = train.drop(columns='Y')
trainY = train.Y

stdsc = StandardScaler()
trainX = stdsc.fit_transform(trainX)

lr = LogisticRegression(C=62)
lr.fit(trainX,trainY)

test = stdsc.transform(test)

y_pred = lr.predict_proba(test)
y_pred = y_pred[:,0]

pd.Series(y_pred).to_csv("testY.csv", sep = ';')