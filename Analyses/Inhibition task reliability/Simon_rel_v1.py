# -*- coding: utf-8 -*-
"""
Created on Fri Sep 28 12:24:30 2018

@author: Curt
"""
import os
import pandas as pd
import numpy as np
import scipy as sci

path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/New Analyses/Reliability"
os.chdir(path)

Simon = pd.read_csv('Simon_rel.txt', sep="\t")
Simon = Simon[["Subject", "Block","Trial","Delay.RT", "TrialCond"]]
Simon.columns = ["Subject", "Block", "Trial", "RT", "Condition"]

Simon.groupby('Block')['RT'].mean()

#Adding trials column that goes to 80 rather than to 40. Need to do on a sub level since trial number differs.
Simon['TrialNew'] = ""
SimonSubs = list(Simon.Subject.unique())
Condition = ['cong', 'incong']
for subject in SimonSubs:
    for condition in Condition:
        temp = Simon[(Simon.Subject == subject) & (Simon.Condition == condition)]
        TempTrialNumb = list(range(1, len(temp) + 1))
        temp['TrialNew'] = TempTrialNumb 
        Simon['TrialNew'][(Simon.Subject == subject) & (Simon.Condition == condition)] = temp['TrialNew']
print('You have sTrAnGe PoWeRs!')

#Test
test = Simon[(Simon['Block'] == 2) & (Simon['TrialNew'] == 1)]

Simon['TrialNew'] = Simon['TrialNew'].astype(int)
#GoodTrials = Simon.groupby('Subject')['TrialNew'].count()
Trial_Numbers = Simon[['Subject', 'TrialNew']].groupby('Subject', as_index=False).max().sort_values('TrialNew')
Trial_Number_Counts = Trial_Numbers.groupby('TrialNew', as_index=False).count()
#Remove extra trials from subject 1.
Simon = Simon[~(Simon['TrialNew'] > 160)]
Trial_Numbers = Simon[['Subject', 'TrialNew']].groupby('Subject', as_index=False).max().sort_values('TrialNew')

#Removing trial and block columns.
Simon['Subject'] = Simon['Subject'].astype(str)
Simon = Simon.drop('Trial', axis=1)
Simon = Simon.drop('Block', axis=1)
Simon.columns = ["Subject", "RT", "Condition", "Trial"]

#Changing case for power functon calls so that they are the same as the Simon.
Simon.loc[Simon['Condition'] == 'cong', 'Condition'] = 'Cong'
Simon.loc[Simon['Condition'] == 'incong', 'Condition'] = 'Incong'

Simon.to_csv("Simon_rel_ready.txt", sep="\t", index=False)

##############################Split half reliability###################################
Simon = pd.read_csv('Simon_rel_ready.txt', sep="\t")
Simon_copy = Simon
#test = Simon[['Subject','Condition','Trial']].groupby(['Subject','Condition'], as_index=False).count()

Simon_cong = Simon_copy[Simon_copy.Condition == 'Cong']

Simon_cong_even = Simon_cong[Simon_cong['Trial'] % 2 == 0]
Simon_cong_even_submeans = Simon_cong_even[['Subject','RT',]].groupby(Simon_cong_even['Subject'], as_index=False).mean().sort_values(by='RT', ascending=False)
Simon_cong_even_submeans.rename({'RT': 'RT_cong'}, axis='columns', inplace=True)

Simon_cong_odd = Simon_cong[Simon_cong['Trial'] % 2 == 1]
Simon_cong_odd_submeans = Simon_cong_odd[['Subject','RT',]].groupby(Simon_cong_odd['Subject'], as_index=False).mean().sort_values(by='RT', ascending=False)
Simon_cong_odd_submeans.rename({'RT': 'RT_cong'}, axis='columns', inplace=True)

Simon_incong = Simon_copy[Simon_copy.Condition == 'Incong']

Simon_incong_even = Simon_incong[Simon_incong['Trial'] % 2 == 0]
Simon_incong_even_submeans = Simon_incong_even[['Subject','RT',]].groupby(Simon_incong_even['Subject'], as_index=False).mean().sort_values(by='RT', ascending=False)
Simon_incong_even_submeans.rename({'RT': 'RT_incong'}, axis='columns', inplace=True)

Simon_incong_odd = Simon_incong[Simon_incong['Trial'] % 2 == 1]
Simon_incong_odd_submeans = Simon_incong_odd[['Subject','RT',]].groupby(Simon_incong_odd['Subject'], as_index=False).mean().sort_values(by='RT', ascending=False)
Simon_incong_odd_submeans.rename({'RT': 'RT_incong'}, axis='columns', inplace=True)

###Reliability calculation
evenSubMeans = Simon_cong_even_submeans.merge(Simon_incong_even_submeans, how='outer')
evenSubMeans['DiffEven'] = evenSubMeans['RT_cong'] - evenSubMeans['RT_incong']
evenSubMeans = evenSubMeans.drop(['RT_cong', 'RT_incong'], axis=1)
oddSubMeans = Simon_cong_odd_submeans.merge(Simon_incong_odd_submeans, how='outer')
oddSubMeans['DiffOdd'] = oddSubMeans['RT_cong'] - oddSubMeans['RT_incong']
oddSubMeans = oddSubMeans.drop(['RT_cong', 'RT_incong'], axis=1)
test_df = evenSubMeans.merge(oddSubMeans, how='outer')
tempCorr = sci.stats.pearsonr(test_df[['DiffEven']], test_df[['DiffOdd']])[0]
tempSpearBrown = (2 * tempCorr) / (1 + tempCorr)