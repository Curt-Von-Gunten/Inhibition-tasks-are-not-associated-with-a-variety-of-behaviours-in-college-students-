# -*- coding: utf-8 -*-
"""
Created on Tue Nov 19 15:39:43 2019

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
outList2 = """Buy MoneyCons FinWB ExerciseReport Fat DietSingle BMI Hyg Sleep 
#TV GamePathScore PhoneTime PhonePath Lifesat Meaning LeisureTot2 DepTot 
#AnxTot AggTot DietDys RelatSat RelatAccNoLoy SchoolEng SchoolStrat 
#SchoolGPA ACTTot WorkPresTot"""
outList2 = re.findall(r"\w+", outList2)
Outcome_df = Ultron[outList1]

####### C) Redoing the table so that *s are added based on p-value #######
### Coefs ###
tempList = []
for x in outList2:
    for y in outList2:
        nas = np.logical_and(Outcome_df[x].notna(), Outcome_df[y].notna())
        tempList.append(stats.pearsonr(Outcome_df[x][nas], Outcome_df[y][nas])[0])
tempList = [Decimal(x).quantize(Decimal('.11'), rounding=ROUND_HALF_UP) for x in tempList]
#tempList = ['%.2f' % elem for elem in tempList]
tempList = np.reshape(tempList,(27,-1))
Coefs = pd.DataFrame(tempList, index=outList2, columns=outList2)

### pvalues ###
tempList = []
for x in outList2:
    for y in outList2:
        nas = np.logical_and(Outcome_df[x].notna(), Outcome_df[y].notna())
        tempList.append(stats.pearsonr(Outcome_df[x][nas], Outcome_df[y][nas])[1])
#tempList = ['%.2f' % elem for elem in tempList]
tempList = np.reshape(tempList,(27,-1))
Pvalues = pd.DataFrame(tempList, index=outList2, columns=outList2)
Pvalues = Pvalues.astype(float)

######## D) Adding *s based on pvalues #######
#Coef_Pval = pd.DataFrame()
#Value = []
#for var in outList2:
#    Value = []
#    tempcoef = []
#    for coef, pval in zip(Coefs[var], Pvalues[var]):
#        if pval < .001:
#            tempcoef = str(coef) + '***'
#        elif pval < .01:
#            tempcoef = str(coef) + '**'
#        elif pval < .05:
#            tempcoef = str(coef) + '*'
#        else:
#            tempcoef = str(coef)
#        Value.append(tempcoef)
#    Coef_Pval[var] = Value 

####### E) Removing leading 0s ####### Note: this was tough because lstrip will remove the '-' sign.
Coefs = Coefs.astype(str)
def Remove_Leading_0s(string):
    return string[0] + string[2:] if string[0] == '-' else string.lstrip('0')
Coef_Pval = Coefs.applymap(lambda x: Remove_Leading_0s(x))

####### F) Adding spaces to top-right half of table #######
column_index = 0
for row in range(0,len(Coef_Pval)):
    Coef_Pval.iloc[row,column_index:27] = ''
    column_index += 1

####### G) Adding a first column of outcome names #######
outcomeLabels = ["Compulsive Spending",
"Monetary Prudence",
"Financial Well-Being",
"Exercise",
"Fat Intake",
"Diet Quality",
"BMI",
"Hygiene", 
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

####### H) Exporting #######
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Figures"
os.chdir(path)
Coef_Pval.to_csv('Outcome_corr_output.txt', sep='\t', index=False)
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Figures"
os.chdir(path)
Coef_Pval.to_csv('Outcome_corr_noast_output.txt', sep='\t', index=False)




