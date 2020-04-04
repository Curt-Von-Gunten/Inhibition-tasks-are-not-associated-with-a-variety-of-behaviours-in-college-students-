# -*- coding: utf-8 -*-
"""
Created on Fri Nov 22 15:49:47 2019

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
Ultron = pd.read_csv('AllData_AnalysisReady_withUPPSfacets.txt', sep='\t')

####### B) Selecting relevant variables ####### 
SelfControlList = ['BriefSC', 'NEOCon', 'UPPS', 'UPPS_PosUrg', 'UPPS_NegUrg', 'UPPS_Prem', 'UPPS_Pers', 'UPPS_Sens']
outList2 = """Buy MoneyCons FinWB ExerciseReport Fat DietSingle BMI Hyg SexRisk Sleep 
#TV GamePathScore PhoneTime PhonePath Lifesat Meaning LeisureTot2 DepTot 
#AnxTot AggTot DietDys RelatSat RelatAccNoLoy SchoolEng SchoolStrat 
#SchoolGPA ACTTot WorkPresTot"""
outList2 = re.findall(r"\w+", outList2)
SC_Outcome_List = SelfControlList + outList2
Ultron = Ultron[SC_Outcome_List]

####### H) Getting the correlations and the p-values separately #######
tempList = []
for dv in outList2:
    for iv in SelfControlList:
        nas = np.logical_and(Ultron[iv].notna(), Ultron[dv].notna())
        tempList.append(stats.pearsonr(Ultron[iv][nas],Ultron[dv][nas])[0])
tempList = [Decimal(x).quantize(Decimal('.11'), rounding=ROUND_HALF_UP) for x in tempList]
tempList = np.reshape(tempList,(28,-1))
coefs = pd.DataFrame(tempList, index=outList2, columns=SelfControlList)

tempList = []
for dv in outList2:
    for iv in SelfControlList:
        nas = np.logical_and(Ultron[iv].notna(), Ultron[dv].notna())
        tempList.append(stats.pearsonr(Ultron[iv][nas],Ultron[dv][nas])[1])
#tempList = ['%.4f' % elem for elem in tempList]
tempList = np.reshape(tempList,(28,-11))
pvalues = pd.DataFrame(tempList, index=outList2, columns=SelfControlList)

####### I) Adding *s based on pvalues #######
Coef_Pval = pd.DataFrame()
Value = []
for var in SelfControlList:
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
final_df['Brief Self-control'] = Coef_df_ordered['BriefSC']
final_df['Conscientiousness'] = Coef_df_ordered['NEOCon']
final_df['UPPS-P'] = Coef_df_ordered['UPPS']
final_df['PosUrge'] = Coef_df_ordered['UPPS_PosUrg']
final_df['NegUrge'] = Coef_df_ordered['UPPS_NegUrg']
final_df['Prem'] = Coef_df_ordered['UPPS_Prem']
final_df['Pers'] = Coef_df_ordered['UPPS_Pers']
final_df['Sens'] = Coef_df_ordered['UPPS_Sens']

####### H) Exporting #######
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Figures"
os.chdir(path)
final_df.to_csv('Self-Control_Outcome_corr_output.txt', sep='\t', index=False)