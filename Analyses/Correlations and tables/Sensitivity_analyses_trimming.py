# -*- coding: utf-8 -*-
"""
Created on Wed Nov 13 16:37:48 2019

@author: Curt
"""

import os
import pandas as pd
import numpy as np
import re
from scipy import stats

####### A) Importing data sets ####### 
### Quest ###
path = "C:/Users/Curt/Box Sync/SASUniversityEdition/myfolders/Dissertation Project"
os.chdir(path)
Quest = pd.read_csv('Quest_Final.txt', sep='\t')
### Raven ###
path = "C:/Users/Curt/Box Sync/SASUniversityEdition/myfolders/Dissertation Project"
os.chdir(path)
Raven = pd.read_csv('Raven_Form.txt', sep='\t')
### DelDis ###
path = "C:/Users/Curt/Box Sync/SASUniversityEdition/myfolders/Dissertation Project"
os.chdir(path)
DelDis = pd.read_csv('DelDis_Form.txt', sep='\t')
### Inhibition ###
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing"
os.chdir(path)
Inhibition = pd.read_csv('LatentScores_MadTrim2.0.txt', sep='\t', header=None, names=['Stop', 'Anti', 'NoGo', 'Simon', 'Stroop', 'Subject', 'Inhibition',' Inhibition(SE)'])

####### B) Cleaning inhibition data ####### 
### Replacing asteriks with missing ###
Inhibition = Inhibition.replace('*', np.NAN)
### Setting inhibition vars to numeric ###
Inhibition['Stop'] = Inhibition['Stop'].astype(float)
Inhibition['Anti'] = Inhibition['Anti'].astype(float)
Inhibition['Stroop'] = Inhibition['Stroop'].astype(float)
Inhibition['NoGo'] = Inhibition['NoGo'].astype(float)
Inhibition['Simon'] = Inhibition['Simon'].astype(float)
### Setting to missing subs that are missing on 2 or more tasks (besides Stop) ###
InhibitionTemp = Inhibition.iloc[:,1:5]
Inhibition['InhibMiss#'] = InhibitionTemp.isna().sum(axis=1) 
Inhibition['Inhibition'][Inhibition['InhibMiss#'] >= 2] = np.NAN
Inhibition['InhibMiss#'].value_counts() #Confirming 20 subs were set to missing.

####### C) Makind list of relevant DVS ####### 
OutcomeList = """Buy MoneyCons FinWB ExerciseReport Fat DietSingle BMI Hyg Sleep 
TV GamePathScore PhoneTime PhonePath Lifesat Meaning LeisureTot2 DepTot 
AnxTot AggTot DietDys RelatSat RelatAccNoLoy SchoolEng SchoolStrat 
SchoolGPA ACTTot WorkPresTot"""
OutcomeList = re.findall(r"\w+", OutcomeList)

####### D) Other cleaning ####### 
### It looks like the bad quest subs have alerady been removed. 
#Quest.isna().sum(axis=1).value_counts()
Quest_small = Quest[OutcomeList]
Quest_small.isna().sum(axis=1).value_counts()

####### E) Merging data sets ####### 
Ultron = Quest.merge(Raven, how='outer', on='Subject', sort=True)
Ultron = Ultron.merge(DelDis, how='outer', on='Subject', sort=True)
Ultron = Ultron.merge(Inhibition, how='outer', on='Subject', sort=True)

####### F) Removing uneeded vars ####### 
CovariatesList = ['Sex', 'SES', 'RavenScore', 'SocDes']
SelfControlList = ['UPPS', 'NEOCon', 'BriefSC']
InhibitionList = ['Inhibition', 'Stop', 'Anti', 'Stroop', 'NoGo', 'Simon']
AllVarList = CovariatesList + SelfControlList + InhibitionList + OutcomeList
Ultron = Ultron[AllVarList]

####### G) Analyses ####### 
tempList = []
for dv in DVList:
    for iv in IVList:
        nas = np.logical_and(Ultron[iv].notna(), Ultron[dv].notna())
        tempList.append(stats.pearsonr(Ultron[iv][nas],Ultron[dv][nas])[0])
tempList = ['%.2f' % elem for elem in tempList]
tempList = np.reshape(tempList,(27,6))
results = pd.DataFrame(tempList, index=DVList, columns=IVList)

#Just inhibition with pvalues.
IVList = ['Inhibition']
tempList = []
for dv in DVList:
    for iv in IVList:
        nas = np.logical_and(Ultron[iv].notna(), Ultron[dv].notna())
        tempList.append(stats.pearsonr(Ultron[iv][nas],Ultron[dv][nas])[0])
tempList = ['%.2f' % elem for elem in tempList]
tempList = np.reshape(tempList,(27,1))
coefs = pd.DataFrame(tempList, index=DVList, columns=IVList)

IVList = ['Inhibition']
tempList = []
for dv in DVList:
    for iv in IVList:
        nas = np.logical_and(Ultron[iv].notna(), Ultron[dv].notna())
        tempList.append(stats.pearsonr(Ultron[iv][nas],Ultron[dv][nas])[1])
tempList = ['%.4f' % elem for elem in tempList]
tempList = np.reshape(tempList,(27,1))
pvalues = pd.DataFrame(tempList, index=DVList, columns=IVList)

newdf = pd.concat([coefs, pvalues], axis=1, keys=['coefs', 'pvalues'])

