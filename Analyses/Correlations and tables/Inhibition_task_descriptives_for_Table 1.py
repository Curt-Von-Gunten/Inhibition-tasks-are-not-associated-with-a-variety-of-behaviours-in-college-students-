# -*- coding: utf-8 -*-
"""
Created on Mon Dec  2 17:01:29 2019

@author: Curt
"""
#%%
import os
import pandas as pd
import numpy as np
from scipy import stats
from decimal import Decimal, ROUND_HALF_UP

####### A) Setting working directory ####### 
### Anti ###
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/New Analyses"
os.chdir(path)
Ultron = pd.read_csv('AllData_AnalysisReady.txt', sep='\t')

#%%
predictors = ['Inhibition', 'Stop', 'Anti', 'Stroop', 'NoGo', 'Simon']
mins = []
maxs = []
means = []
std = []
skew = []
kurt = []
for pred in predictors:
    mins.append(np.nanmin(Ultron[pred]))
    maxs.append(np.nanmax(Ultron[pred]))
    means.append(np.nanmean(Ultron[pred]))
    std.append(np.nanstd(Ultron[pred]))
    skew.append(stats.skew(Ultron[pred], nan_policy='omit'))
    kurt.append(stats.kurtosis(Ultron[pred], nan_policy='omit'))
    
rownames = ['mins', 'maxs', 'means', 'std', 'skews', 'kurts']
array = (np.column_stack((mins, maxs, means, std, skew, kurt))).T
summary_df = pd.DataFrame(array.T, index = predictors, columns = rownames )
summary_df = summary_df.applymap(lambda x: str(Decimal(x).quantize(Decimal('.11'), rounding=ROUND_HALF_UP)))

mins_maxs = []
for min_, max_ in zip(summary_df['mins'], summary_df['maxs']):
    temp_str = str(min_) + " - " + str(max_)
    mins_maxs.append(temp_str)
summary_df['mins-maxs'] = mins_maxs

cols = summary_df.columns.tolist()
cols = cols[-1:] + cols[2:-1]
summary_df = summary_df[cols]
#%%
summary_df = summary_df.reindex(['Inhibition', 'Stop','NoGo', 'Anti', 'Stroop', 'Simon'])

not_missing = [Ultron[pred].notna().sum() for pred in predictors]

print(summary_df)