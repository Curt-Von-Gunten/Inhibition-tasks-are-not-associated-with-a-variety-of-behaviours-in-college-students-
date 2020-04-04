# -*- coding: utf-8 -*-
"""
Created on Mon Aug 29 15:46:59 2018

@author: Curt
"""
import os
import pandas as pd
import numpy as np
import scipy as sci

path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/New Analyses/Reliability"
os.chdir(path)

Stroop = pd.read_csv('Stroop_rel.txt', sep="\t")
Stroop = Stroop[["Subject", "Procedure.Block.","Trial", "condition","Word.ACC", "Word.RT"]]
Stroop.columns = ["Subject", "Block", "Trial", "Condition", "Acc", "RT"]

#Removing incongruent blocks 3 and 4.
Stroop = Stroop[Stroop.Block != 'IncongProc3']
#Renaming values in block.
Stroop.Block[Stroop.Block == 'CongProc1'] = "Cong"
Stroop.Block[Stroop.Block == 'CongProc2'] = "Cong"
Stroop.Block[Stroop.Block == 'IncongProc1'] = "Incong"
Stroop.Block[Stroop.Block == 'IncongProc2'] = "Incong"
#Stroop.Block[Stroop.Block == 'IncongProc3'] = "Incong"
#Adding trials column that goes to 80 rather than to 40. Need to do on a sub level since trial number differs.
Stroop['TrialNew'] = ""
StroopSubs = list(Stroop.Subject.unique())
Block = ['Cong', 'Incong']
for subject in StroopSubs:
    for block in Block:
        temp = Stroop[(Stroop.Subject == subject) & (Stroop.Block == block)]
        TempTrialNumb = list(range(1, len(temp) + 1))
        temp['TrialNew'] = TempTrialNumb 
        Stroop['TrialNew'][(Stroop.Subject == subject) & (Stroop.Block == block)] = temp['TrialNew']
print('You have sTrAnGe PoWeRs!')


#Removing trial and block columns.
Stroop = Stroop.drop('Trial', axis=1)
Stroop = Stroop.drop('Block', axis=1)
Stroop.columns = ["Subject", "Condition", "Acc", "RT", "Trial"]
Stroop.to_csv("Stroop_rel_ready.txt", sep="\t", index=False) 

##############################Split half reliability###################################
Stroop = pd.read_csv('Stroop_rel_ready.txt', sep="\t")
Stroop_copy = Stroop
#test = Stroop[['Subject','Condition','Trial']].groupby(['Subject','Condition'], as_index=False).count()

Stroop_cong = Stroop_copy[Stroop_copy.Condition == 'Cong']

Stroop_cong_even = Stroop_cong[Stroop_cong['Trial'] % 2 == 0]
Stroop_cong_even_submeans = Stroop_cong_even[['Subject','RT',]].groupby(Stroop_cong_even['Subject'], as_index=False).mean().sort_values(by='RT', ascending=False)
Stroop_cong_even_submeans.rename({'RT': 'RT_cong'}, axis='columns', inplace=True)

Stroop_cong_odd = Stroop_cong[Stroop_cong['Trial'] % 2 == 1]
Stroop_cong_odd_submeans = Stroop_cong_odd[['Subject','RT',]].groupby(Stroop_cong_odd['Subject'], as_index=False).mean().sort_values(by='RT', ascending=False)
Stroop_cong_odd_submeans.rename({'RT': 'RT_cong'}, axis='columns', inplace=True)

Stroop_incong = Stroop_copy[Stroop_copy.Condition == 'Incong']

Stroop_incong_even = Stroop_incong[Stroop_incong['Trial'] % 2 == 0]
Stroop_incong_even_submeans = Stroop_incong_even[['Subject','RT',]].groupby(Stroop_incong_even['Subject'], as_index=False).mean().sort_values(by='RT', ascending=False)
Stroop_incong_even_submeans.rename({'RT': 'RT_incong'}, axis='columns', inplace=True)

Stroop_incong_odd = Stroop_incong[Stroop_incong['Trial'] % 2 == 1]
Stroop_incong_odd_submeans = Stroop_incong_odd[['Subject','RT',]].groupby(Stroop_incong_odd['Subject'], as_index=False).mean().sort_values(by='RT', ascending=False)
Stroop_incong_odd_submeans.rename({'RT': 'RT_incong'}, axis='columns', inplace=True)

###Reliability calculation
evenSubMeans = Stroop_cong_even_submeans.merge(Stroop_incong_even_submeans, how='outer')
evenSubMeans['DiffEven'] = evenSubMeans['RT_cong'] - evenSubMeans['RT_incong']
evenSubMeans = evenSubMeans.drop(['RT_cong', 'RT_incong'], axis=1)
oddSubMeans = Stroop_cong_odd_submeans.merge(Stroop_incong_odd_submeans, how='outer')
oddSubMeans['DiffOdd'] = oddSubMeans['RT_cong'] - oddSubMeans['RT_incong']
oddSubMeans = oddSubMeans.drop(['RT_cong', 'RT_incong'], axis=1)
test_df = evenSubMeans.merge(oddSubMeans, how='outer')
tempCorr = sci.stats.pearsonr(test_df[['DiffEven']], test_df[['DiffOdd']])[0]
tempSpearBrown = (2 * tempCorr) / (1 + tempCorr)