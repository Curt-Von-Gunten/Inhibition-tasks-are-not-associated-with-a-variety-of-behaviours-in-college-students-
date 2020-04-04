# -*- coding: utf-8 -*-
"""
Created on Wed Nov 13 15:30:09 2019

@author: Curt
"""

import os
import pandas as pd

####### A) Setting working directory ####### 
### Anti ###
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Anti"
os.chdir(path)
Anti = pd.read_csv('Anti.txt', sep='\t')
### Go ###
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Go"
os.chdir(path)
Go = pd.read_csv('Go.txt', sep='\t')
### Stroop ###
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Stroop"
os.chdir(path)
Stroop = pd.read_csv('Stroop_MadTrim2.5.txt', sep='\t')
### Simon ###
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Simon"
os.chdir(path)
Simon = pd.read_csv('Simon_MadTrim2.5.txt', sep='\t')
### Stop ###
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Stop"
os.chdir(path)
Stop = pd.read_csv('Stop.txt', sep='\t')
Stop.columns = ['Subject', 'Stop_SSD', 'Stop_Acc_NoSig', 'Stop_Acc_Sig', 'Stop_RT_Sig', 'Stop_SSRT_Mean', 'Stop_SSRT_Integ', 'Stop_SSRT_Integ_rev']

####### B) Merging ####### 
combined = Anti.merge(Go, how='outer', on='Subject', sort=True)
combined = combined.merge(Stroop, how='outer', on='Subject', sort=True)
combined = combined.merge(Simon, how='outer', on='Subject', sort=True)
combined = combined.merge(Stop, how='outer', on='Subject', sort=True)

####### C) Keep relevant columns ####### 
combined_red = pd.DataFrame()
combined_red['Subject'] = combined['Subject']
combined_red['Stop_SSRT_Integ_rev'] = combined['Stop_SSRT_Integ_rev']
combined_red['Anti_Acc'] = combined['Anti_Acc']
combined_red['NoGo_Acc'] = combined['NoGo_Acc']
combined_red['Stroop_RT_Diff'] = combined['Stroop_RT_Diff']
combined_red['Simon_RT_Diff'] = combined['Simon_RT_Diff']

####### C) Setting missing values to -999 for Mplus #######
combined_red.loc[combined_red['Stop_SSRT_Integ_rev'].isna(), 'Stop_SSRT_Integ_rev'] = -999 
combined_red.loc[combined_red['Anti_Acc'].isna(), 'Anti_Acc'] = -999
combined_red.loc[combined_red['NoGo_Acc'].isna(), 'NoGo_Acc'] = -999
combined_red.loc[combined_red['Stroop_RT_Diff'].isna(), 'Stroop_RT_Diff'] = -999
combined_red.loc[combined_red['Simon_RT_Diff'].isna(), 'Simon_RT_Diff'] = -999

####### C) Export for Mplus without headers #######
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing"
os.chdir(path)
combined_red.to_csv('Merged_MadTrim2.5.txt', sep='\t', header=False, index=False)
path = "C:/Users/Curt/Desktop/Mplus"
os.chdir(path)
combined_red.to_csv('Merged_MadTrim2.5.txt', sep='\t', header=False, index=False)
