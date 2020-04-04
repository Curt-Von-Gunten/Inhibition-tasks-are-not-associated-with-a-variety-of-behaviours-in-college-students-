# -*- coding: utf-8 -*-
"""
Created on Wed Nov 13 16:37:48 2019

@author: Curt
"""

import os
import pandas as pd
import numpy as np
import re
from decimal import Decimal, ROUND_HALF_UP
import matplotlib.pyplot as plt


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
Inhibition = pd.read_csv('LatentScores_MadTrim2.5.txt', sep='\t', header=None, names=['Stop', 'Anti', 'NoGo', 'Stroop', 'Simon', 'Subject', 'Inhibition',' Inhibition(SE)'])

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

####### C) Makind list of relevant outcomes ####### 
OutcomeList = """Buy MoneyCons FinWB ExerciseReport Fat DietSingle BMI Hyg SexRisk Sleep 
TV GamePathScore PhoneTime PhonePath Lifesat Meaning LeisureTot2 DepTot 
AnxTot AggTot DietDys RelatSat RelatAccNoLoy SchoolEng SchoolStrat 
SchoolGPA ACTTot WorkPresTot"""
OutcomeList = re.findall(r"\w+", OutcomeList)

####### D) Other cleaning ####### 
### It looks like the bad quest subs have alerady been removed. ### 
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
UPPSfacetsList = ['UPPS_PosUrg', 'UPPS_NegUrg', 'UPPS_Prem', 'UPPS_Pers', 'UPPS_Sens']
AllVarList = CovariatesList + SelfControlList + InhibitionList + OutcomeList + UPPSfacetsList
Ultron = Ultron[AllVarList]

####### F) Examining and converting the SexRisk variable to integers by rounding. ####### 
Ultron['SexRisk2'] = Ultron['SexRisk'].apply(lambda x: float(Decimal(x).quantize(Decimal('1'), rounding=ROUND_HALF_UP)))
Ultron['SexRisk'].head(10)
Ultron['SexRisk2'].head(10)
plt.hist(Ultron['SexRisk'], alpha=0.3, label='SexRisk_orig')
plt.hist(Ultron['SexRisk2'], alpha=0.3, label='SexRisk_avg')
plt.legend(loc='upper right')
plt.show()
Ultron['SexRisk2'].astype(pd.Int32Dtype()) #Note that type int doesn't work with nan.
Ultron['SexRisk'] = Ultron['SexRisk2']
Ultron.drop('SexRisk2', axis=1, inplace=True)
#Ultron['SexRisk'] = Ultron['SexRisk'].replace(np.nan,0)

####### F) Making another version of the df that sets missing to . for Mplus ####### 
Ultron_Mplus = Ultron.replace(np.NaN, '.')

####### G) Exporting for Mplus ####### 
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/New Analyses"
os.chdir(path)
Ultron.to_csv('AllData_AnalysisReady_withUPPSfacets.txt', sep='\t', header=True, index=False)




