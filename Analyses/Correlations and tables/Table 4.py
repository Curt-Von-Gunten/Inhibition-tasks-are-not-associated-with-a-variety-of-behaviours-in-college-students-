# -*- coding: utf-8 -*-
"""
Created on Fri Nov 22 14:58:53 2019

@author: Curt
"""
import os
import pandas as pd
import numpy as np
import re
from scipy import stats
from decimal import Decimal, ROUND_HALF_UP

####### A) Setting working directory ####### 
### Anti ###
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/New Analyses"
os.chdir(path)
Ultron = pd.read_csv('AllData_AnalysisReady.txt', sep='\t')

####### B) Selecting relevant variables ####### 
CovariatesList = ['Sex', 'SES', 'RavenScore', 'SocDes']
SelfControlList = ['UPPS', 'NEOCon', 'BriefSC']
InhibitionList = ['Inhibition', 'Stop', 'Anti', 'Stroop', 'NoGo', 'Simon']
TaskList = ['Stop', 'Anti', 'Stroop', 'NoGo', 'Simon']
outList1 = """ACTTot AggTot AnxTot BMI Buy DepTot DietDys DietSingle ExerciseReport Fat  FinWB  GamePathScore  Hyg  LeisureTot2 Lifesat  Meaning MoneyCons PhonePath PhoneTime RelatAccNoLoy RelatSat SchoolEng SchoolGPA SchoolStrat Sleep TV WorkPresTot"""
outList1 = re.findall(r"\w+", outList1)
outList2 = """Buy MoneyCons FinWB ExerciseReport Fat DietSingle BMI Hyg SexRisk Sleep 
#TV GamePathScore PhoneTime PhonePath Lifesat Meaning LeisureTot2 DepTot 
#AnxTot AggTot DietDys RelatSat RelatAccNoLoy SchoolEng SchoolStrat 
#SchoolGPA ACTTot WorkPresTot"""
outList2 = re.findall(r"\w+", outList2)
Inhib_Outcome_List = InhibitionList + outList2
Ultron = Ultron[Inhib_Outcome_List]

####### H) Getting the correlations and the p-values separately #######
tempList = []
for dv in outList2:
    for iv in InhibitionList:
        nas = np.logical_and(Ultron[iv].notna(), Ultron[dv].notna())
        tempList.append(stats.pearsonr(Ultron[iv][nas],Ultron[dv][nas])[0])
#tempList = [Decimal(x).quantize(Decimal('.11'), rounding=ROUND_HALF_UP) for x in tempList]
tempList = np.reshape(tempList,(28,-1))
coefs = pd.DataFrame(tempList, index=outList2, columns=InhibitionList)

tempList = []
for dv in outList2:
    for iv in InhibitionList:
        nas = np.logical_and(Ultron[iv].notna(), Ultron[dv].notna())
        tempList.append(stats.pearsonr(Ultron[iv][nas],Ultron[dv][nas])[1])
#tempList = ['%.4f' % elem for elem in tempList]
tempList = np.reshape(tempList,(28,-11))
pvalues = pd.DataFrame(tempList, index=outList2, columns=InhibitionList)

####### E) Calculating association counts and averages before formatting #######
#%%
coefs = coefs.reset_index(drop=True)
pvalues = pvalues.reset_index(drop=True)
predictors = ['Inhibition', 'Stop', 'Anti', 'Stroop', 'NoGo', 'Simon']
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
    for index, pval in enumerate(pvalues[pred]):
        if pval < .05:
            countdict[pred] += 1
            indexlist.append(index)
    tempSSAs = coefs[pred].iloc[indexlist]
    meansSSA.append(np.nanmean(tempSSAs))
    minsSSA.append(np.nanmin(tempSSAs))
    maxsSSA.append(np.nanmax(tempSSAs))
    means.append(np.nanmean(coefs[[pred]]))
    mins.append(np.nanmin(coefs[[pred]]))
    maxs.append(np.nanmax(coefs[[pred]]))
counts = list(countdict.values())
rownames = ['means', 'mins', 'maxs', 'meansSSA', 'minsSSA', 'maxsSSA', 'counts']
array = np.column_stack((means, mins, maxs, meansSSA, minsSSA, maxsSSA, counts))
summary_df = pd.DataFrame(array.T, index = rownames, columns = predictors)
summary_df = summary_df.applymap(lambda x: str(Decimal(x).quantize(Decimal('.11'), rounding=ROUND_HALF_UP)))
#%%
### Changing the index back in case it is needed for the code below ###
coefs['Outcomes'] = outList2
coefs = coefs.set_index('Outcomes')
pvalues['Outcomes'] = outList2
pvalues = pvalues.set_index('Outcomes')

####### I) Adding *s based on pvalues #######
Coef_Pval = pd.DataFrame()
Value = []
for var in InhibitionList:
    Value = []
    tempcoef = []
    for coef, pval in zip(coefs[var], pvalues[var]):
        if pval < .001:
            tempcoef = str(coef) + '***'
        elif pval < .01:
            tempcoef = str(coef) + '**'
        elif pval < .05:
            tempcoef = str(coef) + '*'
        else:
            tempcoef = str(coef)
        Value.append(tempcoef)
    Coef_Pval[var] = Value 

####### C) Removing leading 0s### Note: using the lstrip method will remove the '-' sign. #######
def Remove_Leading_0s(string):
    return string[0] + string[2:] if string[0] == '-' else string.lstrip('0')
Coef_Pval = Coef_Pval.applymap(lambda x: Remove_Leading_0s(x))

####### G) Adding a first column of outcome names #######
outcomeLabels = ["Compulsive Spending",
"Monetary Prudence",
"Financial Well-Being",
"Exercise",
"Fat Intake",
"Diet Quality",
"BMI",
"Hygiene", 
"Risky Sexual Behavior",
"Sleep Procrastination",
"TV Duration",
"Video Game Pathology",
"Phone Duration",
"Phone Pathology",
"Life Satisfaction",
"Meaning in Life",
"Leisure Orientation",
"Depression",
"Anxiety",
"Aggression",
"Dysregulated Eating",
"Rel. Satisfaction",
"Rel. Accommodation",
"School Engagement",
"Study Habits",
"GPA",
"ACT",
"Work Quality"]

Coef_Pval['Outcome'] = outcomeLabels
cols = Coef_Pval.columns.tolist()
cols = cols[-1:] + cols[:-1]
Coef_Pval = Coef_Pval[cols] 
Coef_df_ordered = Coef_Pval

####### J) Adding blank rows to match the manuscript ####### 
nan_row = pd.Series([np.nan])
Coef_df_ordered = pd.concat([Coef_df_ordered.iloc[:3], nan_row, Coef_df_ordered.iloc[3:10], nan_row,
                 Coef_df_ordered.iloc[10:14], nan_row, Coef_df_ordered.iloc[14:21],
                 nan_row, Coef_df_ordered.iloc[21:23], nan_row, Coef_df_ordered.iloc[23:27],
                 nan_row, Coef_df_ordered.iloc[27:29]], axis=0)
Coef_df_ordered = Coef_df_ordered.iloc[:,1:]
Coef_df_ordered = Coef_df_ordered.reset_index(drop=False)

####### J) Rearanging columns ####### 
final_df = pd.DataFrame()
final_df['Outcome'] = Coef_df_ordered['Outcome']
final_df['Factor Score'] = Coef_df_ordered['Inhibition']
final_df['Stop'] = Coef_df_ordered['Stop']
final_df['Anti'] = Coef_df_ordered['Anti']
final_df['Go/No-Go'] = Coef_df_ordered['NoGo']
final_df['Stroop'] = Coef_df_ordered['Stroop']
final_df['Simon'] = Coef_df_ordered['Simon']

####### H) Exporting #######
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Figures"
os.chdir(path)
final_df.to_csv('Inhibition_Outcome_corr_output.txt', sep='\t', index=False)