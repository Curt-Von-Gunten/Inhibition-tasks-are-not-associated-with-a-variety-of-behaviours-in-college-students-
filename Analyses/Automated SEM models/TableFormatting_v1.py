# -*- coding: utf-8 -*-
"""
Created on Tue Nov 12 13:36:26 2019

@author: Curt
"""

import os
import pandas as pd
import re
from decimal import Decimal, ROUND_HALF_UP
import numpy as np

####### A) Importing data sets ####### 
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/SEM/Automation"
os.chdir(path)
AllPred_Corr = pd.read_csv('AllPred_Corr.txt', sep='\t')

####### B) Using regex to add quotes and commas to the outcome lis ####### 
### Ordered alphabetically to match the R-created file ###
outList1 = """ACTTot AggTot AnxTot BMI Buy DepTot DietDys DietSingle ExerciseReport Fat  FinWB  GamePathScore  Hyg  LeisureToT2 Lifesat  Meaning MoneyCons PhonePath PhoneTime RelatAccNoLoy RelatSat SchoolEng SchoolGPA SchoolStrat Sleep TV WorkPresTot"""
outList1 = re.findall(r"\w+", outList1)
### Ordered according to the manuscript table ###
outList2 = """Buy MoneyCons FinWB ExerciseReport Fat DietSingle BMI Hyg Sleep 
#TV GamePathScore PhoneTime PhonePath Lifesat Meaning LeisureToT2 DepTot 
#AnxTot AggTot DietDys RelatSat RelatAccNoLoy SchoolEng SchoolStrat 
#SchoolGPA ACTTot WorkPresTot"""
outList2 = re.findall(r"\w+", outList2)

####### C) Adding predictor name as first column ####### 
AllPred_Corr['Pred'] = outList1
cols = AllPred_Corr.columns.tolist()
cols = cols[-1:] + cols[:-1]
AllPred_Corr = AllPred_Corr[cols] 

####### D) Making 2 separate dfs in order to loop sequentially in pairs #######Note: This also removes the name column
AllPred_Coef = AllPred_Corr.iloc[:,range(1,13,2)]
AllPred_pval = AllPred_Corr.iloc[:,range(2,13,2)]
### Making columns names the same ###
AllPred_Coef.columns = ['Inhib', 'SC', 'Sex', 'SES', 'Raven', 'SocDes']
AllPred_pval.columns = ['Inhib', 'SC', 'Sex', 'SES', 'Raven', 'SocDes']

####### E) Calculating association counts and averages before formatting #######
predictors = ['Inhib', 'SC', 'Sex', 'SES', 'Raven', 'SocDes']
inhib_SSA_df = pd.DataFrame()
countdict = {}
means = []
mins = []
maxs = []
meansSSA = []
minsSSA = []
maxsSSA = []
for pred in predictors:
    countdict[pred] = 0
    indexlist = []
    for index, pval in enumerate(AllPred_pval[pred]):
        if pval < .05:
            countdict[pred] += 1
            indexlist.append(index)
    tempSSAs = AllPred_Coef[pred].iloc[indexlist]
    meansSSA.append(np.nanmean(tempSSAs))
    minsSSA.append(np.nanmin(tempSSAs))
    maxsSSA.append(np.nanmax(tempSSAs))
    means.append(np.nanmean(AllPred_Coef[[pred]]))
    mins.append(np.nanmin(AllPred_Coef[[pred]]))
    maxs.append(np.nanmax(AllPred_Coef[[pred]]))
counts = list(countdict.values())
rownames = ['means', 'mins', 'maxs', 'meansSSA', 'minsSSA', 'maxsSSA', 'counts']
array = np.column_stack((means, mins, maxs, meansSSA, minsSSA, maxsSSA, counts))
summary_df = pd.DataFrame(array.T, index = rownames, columns = predictors)
summary_df = summary_df.applymap(lambda x: str(Decimal(x).quantize(Decimal('.11'), rounding=ROUND_HALF_UP)))

####### E) Rounding the Coefs before appending the *s #######
AllPred_Coef = AllPred_Coef.applymap(lambda x: str(Decimal(x).quantize(Decimal('.11'), rounding=ROUND_HALF_UP)))

####### F) Removing leading 0s ####### Note: this was tough because lstrip will remove the '-' sign.
def Remove_Leading_0s(string):
    return string[0] + string[2:] if string[0] == '-' else string.lstrip('0')
AllPred_Coef = AllPred_Coef.applymap(lambda x: Remove_Leading_0s(x))
    
####### G) Adding *s based on pvalues #######
Coef_df = pd.DataFrame()
predList = ['Inhib', 'SC', 'Sex', 'SES', 'Raven', 'SocDes']
Coefs = []
for pred in predList:
    Coefs = []
    for coef, pval in zip(AllPred_Coef[pred], AllPred_pval[pred]):
        if pval < .001:
            tempcoef = str(coef) + '***'
        elif pval < .01:
            tempcoef = str(coef) + '**'
        elif pval < .05:
            tempcoef = str(coef) + '*'
        else:
            tempcoef = str(coef)
        Coefs.append(tempcoef)
    Coef_df[pred] = Coefs 

####### H) Putting the predictor name back as the first column ####### 
Coef_df['Pred'] = outList1
cols = Coef_df.columns.tolist()
cols = cols[-1:] + cols[:-1]
Coef_df = Coef_df[cols] 

####### I) Reordering the rows to match the manuscript ####### 
Coef_df_ind = Coef_df.set_index('Pred')
Coef_df_ordered = pd.DataFrame()
for outcome in outList2:
    temp_list = Coef_df_ind.loc[[outcome]]
    Coef_df_ordered = pd.concat([Coef_df_ordered, temp_list], axis=0)

####### J) Adding blank rows to match the manuscript ####### 
nan_row = pd.Series([np.nan])
Coef_df_ordered = pd.concat([Coef_df_ordered.iloc[:3], nan_row, Coef_df_ordered.iloc[3:8], nan_row,
                 Coef_df_ordered.iloc[8:9], nan_row, Coef_df_ordered.iloc[9:13], nan_row, Coef_df_ordered.iloc[13:20],
                 nan_row, Coef_df_ordered.iloc[20:22], nan_row, Coef_df_ordered.iloc[22:26],
                 nan_row, Coef_df_ordered.iloc[26:28]], axis=0)
Coef_df_ordered = Coef_df_ordered.iloc[:,1:]
Coef_df_ordered = Coef_df_ordered.reset_index(drop=False)
    

