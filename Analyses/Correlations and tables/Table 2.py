# -*- coding: utf-8 -*-
"""
Created on Tue Nov 19 15:39:43 2019

@author: Curt
"""
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

####### B) Selecting relevant variables ####### 
CovariatesList = ['Sex', 'SES', 'RavenScore', 'SocDes']
SelfControlList = ['UPPS', 'NEOCon', 'BriefSC']
InhibitionList = ['Inhibition', 'Stop', 'Anti', 'Stroop', 'NoGo', 'Simon']
TaskList = ['Stop', 'Anti', 'Stroop', 'NoGo', 'Simon']
corr_vars = TaskList + SelfControlList
Task_SC = Ultron[corr_vars]

####### H) Redoing the table so that *s are added based on p-value #######
### Coefs ###
Task_SC_List = TaskList + SelfControlList
tempList = []
for x in Task_SC_List:
    for y in Task_SC_List:
        nas = np.logical_and(Task_SC[x].notna(), Task_SC[y].notna())
        tempList.append(stats.pearsonr(Task_SC[x][nas],Task_SC[y][nas])[0])
tempList = [Decimal(x).quantize(Decimal('.11'), rounding=ROUND_HALF_UP) for x in tempList]
#tempList = ['%.2f' % elem for elem in tempList]
tempList = np.reshape(tempList,(8,-1))
Coefs = pd.DataFrame(tempList, index=Task_SC_List, columns=Task_SC_List)

### pvalues ###
tempList = []
for x in Task_SC_List:
    for y in Task_SC_List:
        nas = np.logical_and(Task_SC[x].notna(), Task_SC[y].notna())
        tempList.append(stats.pearsonr(Task_SC[x][nas],Task_SC[y][nas])[1])
#tempList = ['%.2f' % elem for elem in tempList]
tempList = np.reshape(tempList,(8,-1))
Pvalues = pd.DataFrame(tempList, index=Task_SC_List, columns=Task_SC_List)
Pvalues = Pvalues.astype(float)

####### I) Adding *s based on pvalues #######
Coef_Pval = pd.DataFrame()
Value = []
for var in Task_SC_List:
    Value = []
    tempcoef = []
    for coef, pval in zip(Coefs[var], Pvalues[var]):
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

####### J) Adding blanks to the top-right half of the table #######
column_index = 0
for row in range(0,len(Coef_Pval)):
    Coef_Pval.iloc[row,column_index:8] = ''
    column_index += 1
    
    
#############################################################################################
####### It turns out I need the p-values for the *s. df.corr() does not provide these #######
#############################################################################################
####### A) Getting correlation matrix. This method excludes null values. ####### 
Task_SC_corr = Task_SC.corr()

####### B) Rounding the corrs ####### 
Task_SC_corr = Task_SC_corr.applymap(lambda x: str(Decimal(x).quantize(Decimal('.11'), rounding=ROUND_HALF_UP)))

####### C) Removing leading 0s### Note: using the lstrip method will remove the '-' sign. #######
def Remove_Leading_0s(string):
    return string[0] + string[2:] if string[0] == '-' else string.lstrip('0')
Task_SC_corr = Task_SC_corr.applymap(lambda x: Remove_Leading_0s(x))
    
####### D) Getting means of relevant correlations sets #######
### Converting to numpy array ###
corr_array = Task_SC_corr.astype(float)
### Inhibition tasks ###
Inhibition_corr = np.nanmean(corr_array.iloc[0:5,0:5])
Inhibition_corr = float(Decimal(Inhibition_corr).quantize(Decimal('.11'), rounding=ROUND_HALF_UP))
### Self-control tasks ###
SC_corr = np.nanmean(corr_array.iloc[5:,5:9])
SC_corr = float(Decimal(SC_corr).quantize(Decimal('.11'), rounding=ROUND_HALF_UP))
### Self-control tasks ###
Inhib_SC_corr = np.nanmean(corr_array.iloc[5:,0:5])
Inhib_SC_corr = float(Decimal(Inhib_SC_corr).quantize(Decimal('.11'), rounding=ROUND_HALF_UP))

Corr_Avgs = {'Inhibition_corr': Inhibition_corr, 'Self-control_corr': SC_corr, 'Inhib_SC_corr': Inhib_SC_corr}
