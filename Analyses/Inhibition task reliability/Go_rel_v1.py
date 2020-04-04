# -*- coding: utf-8 -*-
"""
Created on Tue May 21 18:03:06 2019

@author: cv85
"""

# -*- coding: utf-8 -*-
"""
Created on Tue May 21 16:36:59 2019

@author: cv85
"""

import os
import pandas as pd
import numpy as np
############################################################################
def CronbachAlpha(itemscores):
    itemscores = np.asarray(itemscores)
    itemvars = itemscores.var(axis=0, ddof=1)
    tscores = itemscores.sum(axis=1)
    nitems = itemscores.shape[1]
    calpha = nitems / float(nitems-1) * (1 - itemvars.sum() / float(tscores.var(ddof=1)))
    return calpha
############################################################################
path = "C:/Users/Curt\Box Sync/Duke Box (9-4-2019)/Simulation Project_10-32/Simulation Project_10-32/Data_Code_Output/Go/Revision"
os.chdir(path)
Go = pd.read_csv('Go_Ready_Revision.txt', sep="\t")
Go = Go[Go['Trial'] <= 79]
##############################Sequential without random sampling########################################
go_wide = pd.pivot_table(Go,index='Subject',columns='Trial',values='Acc')
go_Alpha = CronbachAlpha(go_wide)
