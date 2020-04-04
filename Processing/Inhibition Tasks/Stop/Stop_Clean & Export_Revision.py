# -*- coding: utf-8 -*-
"""
Created on Sun Sep 30 19:37:24 2018

@author: Curt
"""

import os
import pandas as pd
import numpy as np
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Stop"
os.chdir(path)

##############################################################
Stop = pd.read_csv('SS_AllSubs.txt', sep="\t")
Stop = Stop.drop('re', axis=1)
Stop = Stop.drop('stimulus', axis=1)
Stop.columns = ["Subject", "Block", "Trial",  "TrialType", "Acc", "Response", "RT", "SSD"]

#See SAS code for why I'm removing these subjects.
Stop = Stop[Stop.Subject != 245]
Stop = Stop[Stop.Subject != 363]
Stop = Stop[Stop.Subject != 376]

#Recoding values.
Stop.loc[Stop['Acc']==2, 'Acc'] = 1
#Checking the coding for TrialType.
#TrialType: 0 = Not-Stop; 1 = Stop.
#Response: 0 = No Response.
TrialNumber_Count = Stop.groupby(['Subject','TrialType'])['Acc'].count()
Stop.loc[Stop['TrialType']==0, 'TrialType'] = 'NotStop'
#Stop['TrialType'] = Stop['TrialType'].replace(0, 'NotStop')  Another method for replacing values in a column.
#The R-like method below. Called 'chained assignment'.
#Stop['RT'][(Stop['TrialType']==0) & (Stop['Response']==0)] = ""
Stop.loc[Stop['TrialType']==1, 'TrialType'] = 'Stop'
Stop.loc[Stop['TrialType']=='NotStop', 'SSD'] = ''
Stop.loc[Stop['Response']== 0, 'Response'] = 'NoResponse'
Stop.loc[Stop['Response']== 1, 'Response'] = 'Square'
Stop.loc[Stop['Response']== 2, 'Response'] = 'Circle'

#Removing rows with -1s.
Stop = Stop[Stop.Acc != -1]
Stop.Acc.describe() #Checking.

#If Stop trial, then remove RT.
Stop.loc[Stop['TrialType'] == 'Stop', 'RT'] = np.NaN
#If NotStop trial, then remove SSD.
Stop.loc[Stop['TrialType']=='NotStop', 'SSD'] = np.NaN

#Removing Subjects with 0% accuracy.
Acc = pd.DataFrame(Stop.groupby(['Subject','TrialType'])['Acc'].mean())
Acc.reset_index(inplace=True)
BadSubs = pd.DataFrame(Acc.loc[Acc.Acc==0]['Subject'])
Stop = Stop[-Stop.Subject.isin(BadSubs.Subject)]
Acc = pd.DataFrame(Stop.groupby(['Subject','TrialType'])['Acc'].mean())
Acc.reset_index(inplace=True)

#DELETING incorrect NotStop trials. This covers commission and ommission errors.
#Save a dataset with those errors first. I'll need this later to remove Ps based on accuracy.
StopAcc = Stop
#Stop.loc[(Stop['TrialType'] == 'NotStop') & (Stop['Acc'] == 0),'RT'] = np.NaN
Stop = Stop[(Stop['TrialType'] != 'NotStop') | (Stop['Acc'] != 0)]

Stop.dtypes
Stop[['SSD']] = pd.to_numeric(Stop.SSD, errors='coerce')
Stop.dtypes
    
#SSD = pd.DataFrame(Stop.groupby(['Subject','TrialType'])['SSD'].mean())
#SSD2 = pd.DataFrame(Stop.groupby(['Subject'])['SSD'].mean())
#Checking to see if 'mean' skipps missing values.
#print(SSD)
#print(SSD2)

#Checking trial counts.
#For Stop trials.
#min(Stop.groupby(['Subject','Block'])['SSD'].count())
#Checking the number of correct trials in each block for NotStop trials.
#TrialCount = Stop.groupby(['Subject','Block'])['RT'].count()
#min(Stop.groupby(['Subject','Block'])['RT'].count())


#Adding trials column.
Stop = Stop.sort_values(by = ['Subject', 'TrialType', 'Block', 'Trial'])
Stop['TrialNew'] = ""
StopSubs = list(Stop.Subject.unique())
Condition = ['Stop', 'NotStop']
for subject in StopSubs:
    for condition in Condition:
        temp = Stop[(Stop.Subject == subject) & (Stop.TrialType == condition)]
        TempTrialNumb = list(range(1, len(temp) + 1))
        temp['TrialNew'] = TempTrialNumb
        Stop['TrialNew'][(Stop.Subject == subject) & (Stop.TrialType == condition)] = temp['TrialNew'] 
print('You have sTrAnGe PoWeRs!')

SubMax = Stop[['Subject','TrialNew','TrialType']].groupby(['Subject','TrialType'], as_index=False).count()
Trial_Number_Counts = SubMax[['Subject','TrialType','TrialNew']].groupby(['TrialType','TrialNew'], as_index=False).count()
Max = SubMax[['TrialNew','TrialType']].groupby('TrialType').max()
Min = SubMax[['TrialNew','TrialType']].groupby('TrialType').min()
Stop = Stop.sort_values(by = ['Subject', 'TrialType', 'Block', 'TrialNew'])
#Removing trial and block columns.
Stop2 = Stop.drop('Trial', axis=1)
Stop2 = Stop2.drop('Block', axis=1)
Stop2 = Stop2.drop('Response', axis=1)
Stop2.columns = ["Subject", "TrialType", "Acc", "RT", "SSD", "Trial"]




#########################################################
#####Removal based on accuracy#########
#Stop trials first
AccMean = pd.DataFrame(Stop.groupby(['Subject','TrialType'], as_index=False)['Acc'].mean())
AccMean = AccMean[AccMean['TrialType'] == 'Stop']
#Now NotStop trials.
StopAccMean = pd.DataFrame(StopAcc.groupby(['Subject','TrialType'], as_index=False)['Acc'].mean())
StopAccMean = StopAccMean[StopAccMean['TrialType'] == 'NotStop']

#Checking
import matplotlib.pyplot as plt
plt.hist(AccMean['Acc'], bins='auto')  # arguments are passed to np.histogram
plt.title("Stop Acc")
plt.show()
plt.hist(StopAccMean['Acc'], bins='auto')  # arguments are passed to np.histogram
plt.title("NotStop Acc")
plt.show()

#Removing: Less than 80% for NotStop; Less than 20% for Stop. Based on diss manuscript.
StopRem = AccMean[AccMean.Acc < .20]
NotStopRem = StopAccMean[StopAccMean.Acc < .80]
len(StopRem)
len(NotStopRem)
BadSubsAcc1 = list(StopRem['Subject'])
BadSubsAcc2 = list(NotStopRem['Subject'])
BadSubsAcc = BadSubsAcc1 + BadSubsAcc2
len(BadSubsAcc)

AccMeanRem = AccMean[AccMean.Acc >= .20]
StopAccMeanRem = StopAccMean[StopAccMean.Acc >= .80]
plt.hist(AccMeanRem['Acc'], bins='auto')  # arguments are passed to np.histogram
plt.title("Stop Acc")
plt.show()
plt.hist(StopAccMeanRem['Acc'], bins='auto')  # arguments are passed to np.histogram
plt.title("NotStop Acc")
plt.show()
 

Stop2Rem = Stop2[-Stop2.Subject.isin(BadSubsAcc)]
len(Stop2['Subject'].unique()) - len(Stop2Rem['Subject'].unique())

#Removing two subjects who did not complete all of the blocks.
TrialNumber_Count = Stop2Rem.groupby(['Subject','TrialType'], as_index=False)['Acc'].count()
BadSubsTrialNumber = TrialNumber_Count['Subject'][TrialNumber_Count['Acc'] < 48]
Stop3Rem = Stop2Rem[-Stop2Rem.Subject.isin(BadSubsTrialNumber)]
len(Stop2Rem['Subject'].unique()) - len(Stop3Rem['Subject'].unique())
##############Export##########################
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/New Analyses/Reliability"
os.chdir(path)
#Data for similation.
Stop3Rem.to_csv("Stop_rel.txt", sep="\t", index=False) 







####Here's the process that computes SSRT.
RTMean = pd.DataFrame(Stop.groupby(['Subject','TrialType'])['RT'].mean())
RTMean.reset_index(inplace=True)
RTMean = RTMean[RTMean['TrialType'] == 'NotStop']
SSDMean = pd.DataFrame(Stop.groupby(['Subject','TrialType'])['SSD'].mean())
SSDMean.reset_index(inplace=True)
SSDMean = SSDMean[SSDMean['TrialType'] == 'Stop']
StopSubLev = pd.merge(RTMean, SSDMean, on='Subject')
StopSubLev = StopSubLev.drop('TrialType_x', axis=1)
StopSubLev = StopSubLev.drop('TrialType_y', axis=1)
StopSubLev['SSRT'] = StopSubLev['RT'] - StopSubLev['SSD']


#########################Winsorizing based on SSRT. This is irrelevant for simulations#####
plt.hist(StopSubLevRem['SSRT'], bins='auto')  # arguments are passed to np.histogram
plt.title("SSRTRem")
plt.show()
plt.hist(StopSubLev['SSRT'], bins='auto')  # arguments are passed to np.histogram
plt.title("SSRT")
plt.show()

np.std(StopSubLevRem['SSRT'])
StopSubLevRem.loc[StopSubLevRem['SSRT'] > 
              StopSubLevRem['SSRT'].mean() + (np.std(StopSubLevRem['SSRT']) * 3), 'SSRT'] = StopSubLevRem['SSRT'].mean() + (np.std(StopSubLevRem['SSRT']) * 3)
StopSubLevRem.loc[StopSubLevRem['SSRT'] < 
              StopSubLevRem['SSRT'].mean() - (np.std(StopSubLevRem['SSRT']) * 3), 'SSRT'] = StopSubLevRem['SSRT'].mean() - (np.std(StopSubLevRem['SSRT']) * 3)

plt.hist(StopSubLevRem['SSRT'], bins='auto')  # arguments are passed to np.histogram
plt.title("SSRTAfter")
plt.show()

