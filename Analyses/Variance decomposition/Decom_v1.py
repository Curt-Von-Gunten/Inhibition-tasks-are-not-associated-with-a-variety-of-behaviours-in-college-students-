# -*- coding: utf-8 -*-
"""
Created on Thu May  9 15:02:32 2019

@author: cv85
"""
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
######################################################################################
############################Functions#################################################
######################################################################################
def CronbachAlpha1(itemscores):
    itemscores = np.asarray(itemscores)
    itemvars = itemscores.var(axis=0, ddof=1)
    tscores = itemscores.sum(axis=1)
    nitems = itemscores.shape[1]
    calpha1 = nitems / float(nitems-1) * (1 - itemvars.sum() / float(tscores.var(ddof=1)))
    return calpha1

def CronbachAlpha2(itemscores):
    itemscores = np.asarray(itemscores)
    grandMean = itemscores.sum(axis=0).sum() / (itemscores.shape[0] * itemscores.shape[1])
    itemMeans = itemscores.mean(axis=0)  
    nSubs = itemscores.shape[0]
    subMeans = itemscores.mean(axis=1)
    nItems = itemscores.shape[1]
    SStot = ((itemscores - grandMean) **2).sum() 
    SSitem = (nSubs * (itemMeans - grandMean)**2).sum()
    SSsub = (nItems * (subMeans - grandMean)**2).sum()
    SSerr = SStot - SSitem - SSsub
    DFitem = itemscores.shape[1] - 1
    DFsub = itemscores.shape[0] - 1
    DFerr = (itemscores.shape[0] - 1) * (itemscores.shape[1] - 1)
    MSitem = SSitem/DFitem
    MSsub = SSsub/DFsub
    MSerr = SSerr/DFerr
    MSsum = MSsub + MSitem + MSerr
    MSsub_per = (MSsub / MSsum) * 100
    MSiten_per = (MSitem / MSsum) * 100
    MSerr_per = (MSerr / MSsum) * 100
    MSsub_per + MSiten_per + MSerr_per
    calpha2 = 1 - (MSerr/MSsub)
    return calpha2, MSsub_per, MSiten_per, MSerr_per, MSsub, MSitem, MSerr
######################################################################################
##############Variance decomposition of the three measures############################
######################################################################################
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Data"
os.chdir(path)
Quest = pd.read_csv('Quest_Final_AllVarForDescriptives.txt', sep="\t")
###################Brief self-control scale######################
#Making item names and indexing dataframe
BreifscnameList = ['Subject']
for i in range(1,14):
    BreifscnameList.append('BriefSC' + str(i))
breifsc_DF = Quest[BreifscnameList]

#Imputing missing values
#This took forever because I couldn't figure out why nan wasn't being filled. It seems that .mdeian returns a series. I had to convert it to a list and then grab the single element. There is also an issue with inplace not working. Had to append to a new DF,
breifsc_DF.isnull().sum()
breifsc_DF_nullremoved = pd.DataFrame(columns=[BreifscnameList])
breifsc_DF_nullremoved.columns = [x.strip('",') for x in BreifscnameList]
Subjects = Quest['Subject'].unique()
for sub in Subjects:
     tempRow = breifsc_DF[breifsc_DF['Subject'] == sub].fillna(breifsc_DF[breifsc_DF['Subject'] == sub].drop('Subject', axis=1).median(skipna=True, axis=1).tolist()[0])
     breifsc_DF_nullremoved = breifsc_DF_nullremoved.append(tempRow)
breifsc_DF_nullremoved.isnull().sum()

#Running function and reformatting.
breifsc_DF_nullremoved.drop(columns=['Subject'], inplace=True)
briefscVar = CronbachAlpha2(breifsc_DF_nullremoved)
briefscVar = np.reshape(briefscVar, (1, -1)) 
briefscVarDF = pd.DataFrame(briefscVar, columns=["Alpha", "MSsub", "MSitem", "MSerr", "MSsub_abs", "MSitem_abs", "MSerr_abs"])
      
############################UPPS-P###############################
#Making item names and indexing dataframe
UPPSnameList = ['Subject']
for i in range(1,49):
    UPPSnameList.append('UPPS_P' + str(i))
upps_DF = Quest[UPPSnameList]

#Imputing missing values
upps_DF.isnull().sum()
upps_DF_nullremoved = pd.DataFrame(columns=[UPPSnameList])
upps_DF_nullremoved.columns = [x.strip('",') for x in UPPSnameList]
Subjects = Quest['Subject'].unique()
for sub in Subjects:
     tempRow = upps_DF[upps_DF['Subject'] == sub].fillna(upps_DF[upps_DF['Subject'] == sub].drop('Subject', axis=1).median(skipna=True, axis=1).tolist()[0])
     upps_DF_nullremoved = upps_DF_nullremoved.append(tempRow)
upps_DF_nullremoved.isnull().sum()

#Running function and reformatting.
upps_DF_nullremoved.drop(columns=['Subject'], inplace=True)
uppsVar = CronbachAlpha2(upps_DF_nullremoved)
uppsVar = np.reshape(uppsVar, (1, -1)) 
uppsVarDF = pd.DataFrame(uppsVar, columns=["Alpha", "MSsub", "MSitem", "MSerr", "MSsub_abs", "MSitem_abs", "MSerr_abs"])
      
#########################Conscientiousness########################
#Making item names and indexing dataframe
ConsnameList = ['Subject','NEO3','NEO8']
cons_DF = Quest[ConsnameList]

#Imputing missing values
cons_DF.isnull().sum()
cons_DF_nullremoved = pd.DataFrame(columns=[ConsnameList])
cons_DF_nullremoved.columns = [x.strip('",') for x in ConsnameList]
Subjects = Quest['Subject'].unique()
for sub in Subjects:
     tempRow = cons_DF[cons_DF['Subject'] == sub].fillna(cons_DF[cons_DF['Subject'] == sub].drop('Subject', axis=1).median(skipna=True, axis=1).tolist()[0])
     cons_DF_nullremoved = cons_DF_nullremoved.append(tempRow)
cons_DF_nullremoved.isnull().sum()

#Running function and reformatting.
cons_DF_nullremoved.drop(columns=['Subject'], inplace=True)
consVar = CronbachAlpha2(cons_DF_nullremoved)
consVar = np.reshape(consVar, (1, -1)) 
consVarDF = pd.DataFrame(consVar, columns=["Alpha", "MSsub", "MSitem", "MSerr", "MSsub_abs", "MSitem_abs", "MSerr_abs"])
######################################################################################
###################Variance decomposition of the two tasks############################
######################################################################################
#########################Antisaccade########################
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Code and Figures"
os.chdir(path)
Anti = pd.read_csv('Anti_Ready_Revision.txt', sep="\t")
Anti_wide = pd.pivot_table(Anti,index='Subject',columns='Trial',values='Acc')
Anti_vardecomp = CronbachAlpha2(Anti_wide)
Anti_vardecomp = np.reshape(Anti_vardecomp, (1, -1)) 
antiVarDF = pd.DataFrame(Anti_vardecomp, columns=["Alpha", "MSsub", "MSitem", "MSerr", "MSsub_abs", "MSitem_abs", "MSerr_abs"])
#############################Go##############################
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Code and Figures"
os.chdir(path)
Go = pd.read_csv('Go_Ready_Revision.txt', sep="\t")
Go = Go[Go['Trial'] < 80]
Go_wide = pd.pivot_table(Go,index='Subject',columns='Trial',values='Acc')
Go_vardecomp = CronbachAlpha2(Go_wide)
Go_vardecomp = np.reshape(Go_vardecomp, (1, -1)) 
goVarDF = pd.DataFrame(Go_vardecomp, columns=["Alpha", "MSsub", "MSitem", "MSerr", "MSsub_abs", "MSitem_abs", "MSerr_abs"])
######################################################################################
#########################Combining the five measures##################################
######################################################################################
briefscVarDF['Measure'] = 'BriefSC'
uppsVarDF['Measure'] = 'UPPS-P'
consVarDF['Measure'] = 'Conscientiousness'
antiVarDF['Measure'] = 'Antisaccade'
goVarDF['Measure'] = 'Go/no-go'
SCMeasures_Var = pd.concat([briefscVarDF, uppsVarDF, consVarDF, antiVarDF, goVarDF], ignore_index=True)

######################################################################################
############################Plotting#################################################
######################################################################################
path = "C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJop"
os.chdir(path)  
#################Relative variance##################################
#Just with Trial.
#sns.set(style="whitegrid", font_scale=1.2)
#mpl.style.use('fivethirtyeight')
#mpl.style.use('ggplot')
#mpl.style.use('bmh')
#mpl.style.use('seaborn-muted')
#mpl.style.use('grayscale')
#mpl.style.use('dark_background')
#################Relative variance. Trial Only######################
greenBars = np.asanyarray(SCMeasures_Var['MSsub']) 
orangeBars = np.asanyarray(SCMeasures_Var['MSitem'])
blueBars = np.asanyarray(SCMeasures_Var['MSerr'])
Alpha_scaled = np.asanyarray(SCMeasures_Var['Alpha'] * 100)
r = range(1, len(SCMeasures_Var)+1)
barWidth = 0.8
names = SCMeasures_Var['Measure'].tolist()

plt.style.use('grayscale')
plt.figure(facecolor="white")
plt.bar(r, greenBars, width=barWidth, label="Between subject")
plt.bar(r, orangeBars, bottom=greenBars, width=barWidth, label="Between item")
plt.bar(r, blueBars, bottom=[i+j for i,j in zip(greenBars, orangeBars)], width=barWidth, label="Error")
plt.plot(r, Alpha_scaled, marker="D", linestyle="", color="w", label="Cronbach's Alpha")

plt.xticks(r, names, rotation=15)
plt.xlabel("Measures")
plt.ylabel("% of total variation")
#plt.title("Variance decomposition of antisaccade")
#plt.grid(color='w', linestyle='-', linewidth=2, axis='y')
plt.legend(loc='lower right')
plt.show()
plt.savefig('All_Var_Decomp_rel.tiff', bbox_inches = 'tight', dpi=300)


#################Absolute variance. Trial only#####################
greenBars = np.asanyarray(SCMeasures_Var['MSsub_abs']) 
orangeBars = np.asanyarray(SCMeasures_Var['MSitem_abs'])
blueBars = np.asanyarray(SCMeasures_Var['MSerr_abs'])
Alpha = np.asanyarray(SCMeasures_Var['Alpha'])
r = range(1, len(SCMeasures_Var)+1)
barWidth = 0.8
#Making names
names = SCMeasures_Var['Measure'].tolist()

plt.style.use('grayscale')
plt.figure(facecolor="white")
plt.bar(r, greenBars, width=barWidth, label="Between subject")
plt.bar(r, orangeBars, bottom=greenBars, width=barWidth, label="Between item")
plt.bar(r, blueBars, bottom=[i+j for i,j in zip(greenBars, orangeBars)], width=barWidth, label="Error")
#plt.plot(r, Alpha, marker="D", linestyle="", color="w", label="Cronbach's Alpha")

plt.xticks(r, names, rotation=15)
plt.xlabel("Number Measures trials")
plt.ylabel("Mean squared units")
#plt.title("Variance decomposition of antisaccade")
plt.legend(loc='upper right')
plt.show()
plt.savefig('All_Var_Decomp_abs.tiff', bbox_inches = 'tight', dpi=300)



##############################Export######################################
#plt.savefig('Anti_Seq_Decom_rel.pdf', bbox_inches = 'tight')
#plt.savefig('Anti_Seq_Decom_abs.pdf', bbox_inches = 'tight')

#Reset defaults. 
mpl.rcParams.update(mpl.rcParamsDefault)


