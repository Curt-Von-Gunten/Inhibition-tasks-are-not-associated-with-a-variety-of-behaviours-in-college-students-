
require(reshape2)
require(plyr)
require(dplyr)
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Stop")

Alldat <- read.delim(file = "SS_AllSubs_Go.txt", header = T, sep = "\t")
Stop <- read.delim(file = "SS_Stop.txt", header = T, sep = "\t")


#Removing the perfect accuracy peeps. This decreases the processing time of the loops below. The different sizes bewteen the 
#signal and non-signal datasets doesn't matter, since the code just uses the non-signal data to select whatever is in it from
#the signal data.
#Alldat <- Alldat[Alldat$AccAvg != 0,]

#####Adding block level accuracy and SSD from Signal dataset to the non-signal dataset.####
for (i in unique(Alldat$Subject)){
  for (j in unique(Alldat$block)){
    for (k in unique(Alldat$trial)){
      Alldat$AccAvg[Alldat$Subject == i & Alldat$block == j & Alldat$trial == k] <- mean(Stop$Accuracy_rev[Stop$Subject == i & Stop$block == j])
      Alldat$SSD[Alldat$Subject == i & Alldat$block == j & Alldat$trial == k] <- mean(Stop$ssd[Stop$Subject == i & Stop$block == j])
    }
  }
}

####Getting Number of trials for each block####
Alldat <- Alldat[Alldat$correct == 2,]

for (i in unique(Alldat$Subject)){
  for (j in unique(Alldat$block)){
    for (k in unique(Alldat$trial)){
      Alldat$TrialNum[Alldat$Subject == i & Alldat$block == j & Alldat$trial == k] <- length(Alldat$trial[Alldat$Subject == i & Alldat$block == j])
    }
  }
}

#Sorting rt within Subject and block.
Alldat <- Alldat[order(Alldat$Subject, Alldat$block, Alldat$rt),]

#Need to make a trial index.
#Attempting with "rep" command.
for (i in unique(Alldat$Subject)){
  for (j in unique(Alldat$block)){
    Alldat$Index[Alldat$Subject == i & Alldat$block == j] <- (rep(1:length(unique(Alldat$trial))))
  }
}

#Removing the perfect accuracy peeps.
Alldat <- Alldat[Alldat$AccAvg != 1,]

#Then multiplay accuracy by TrialNum to get nthTrial
Alldat$nthTrial <- round(Alldat$AccAvg * Alldat$TrialNum)

#Removing a bunch of strange completely missing data at the end. Probably due to different size of Stop and Alldat.
Alldat <- Alldat[!is.na(Alldat$AccAvg),]

#Subject 61 has one trial for third block. Need to remove this because an nthRt is not possible.
Alldat <- Alldat[Alldat$Subject != 61 | Alldat$block != 2,]
Sub61 <- Alldat[Alldat$Subject == 61,]

#Then select the nthRT where Index is equal to the nthTrial.
for (i in unique(Alldat$Subject)){
  for (j in unique(Alldat$block)){
    for (k in unique(Alldat$trial)){
      Alldat$nthRT[Alldat$Subject == i & Alldat$block == j & Alldat$trial == k] <- Alldat$rt[Alldat$Subject == i & Alldat$block == j & Alldat$Index == Alldat$nthTrial]
    }
  }
}

#Subtracting mean SSD from the nth RT.
Alldat$SSRT <- Alldat$nthRT - Alldat$SSD

#Outputing data to txt.
write.table(Alldat, "IntegrateFromR.txt", sep = "\t", row.names = F)

#Getting the data at the block level (one row per block) by removing duplicates.
SSRT <- Alldat[,c("Subject", "block", "SSRT")]
SSRT <- unique(SSRT[,1:3])

#Averging the block SSRTs. I think I could have done this directly whithout needing to convert to the block level.
dat1 <- select(SSRT, Subject, block, SSRT)
dat2 <- group_by(dat1, Subject) 
(SSRT_SubLev <-   summarise(dat2, mean(SSRT)))
colnames(SSRT_SubLev) <- c("Subject", "SSRT")

#Outputing data to txt.
write.table(SSRT_SubLev, "IntegrateFromR_SubLev.txt", sep = "\t", row.names = F)




##################Duplicating the Between-Subs Cleaning from SAS####################.
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Stop")
SS_Mean <- read.delim(file = "Mean-based_SSRT.txt", header = T, sep = "\t")
#In order to skip the code above (which takes awhile to run) can import the output dataset directly.
SS_Integ <- read.delim(file = "IntegrateFromR_SubLev.txt", header = T, sep = "\t")


########Removing variables and merging############
colnames(SS_Mean) <- c("Subject", "SSD", "Acc_NoSig", "Acc_Sig", "RT_Sig", "SSRT_Mean") 
colnames(SS_Integ) <- c("Subject", "SSRT_Integ")
SS <- merge(SS_Mean, SS_Integ, by = "Subject")
SS$SSRT_Mean[is.na(SS$SSRT_Integ)] <- NA
SS$SSD[is.na(SS$SSRT_Integ)] <- NA
SS$Acc_Sig[is.na(SS$SSRT_Integ)] <- NA
SS$Acc_NoSig[is.na(SS$SSRT_Integ)] <- NA
SS$RT_Sig[is.na(SS$SSRT_Integ)] <- NA
SS <- SS[!is.na(SS$SSRT_Integ) ,]

#NoSig removal.
hist(SS$Acc_NoSig)
hist(SS$Acc_Sig)
hist(SS$SSRT_Integ)
SS_Num_Removed <- SS[SS$Acc_NoSig < .80,]
SS_rem <- SS[!SS$Acc_NoSig < .80,]
hist(SS_rem$Acc_NoSig)
hist(SS_rem$Acc_Sig)
hist(SS_rem$SSRT_Integ)

#Signal removal.
SS_Num_Removed2 <- SS_rem[SS_rem$Acc_Sig < .20,]
SS_rem2 <- SS_rem[!SS_rem$Acc_Sig < .20,]
hist(SS_rem2$Acc_NoSig)
hist(SS_rem2$Acc_Sig)
hist(SS_rem2$SSRT_Integ)

#Removing Subs who have 0% accuracy in at least one block.
Stop_only <- read.delim(file = "SS_Stop.txt", header = T, sep = "\t")
###########Getting block and subject level averages##############
#Note that if you import plyr after dplyr this code won't work do to replacing functions that have the same name and other reasons.
dat1 <- select(Stop_only, Subject, block, Accuracy)
dat2 <- group_by(dat1, Subject, block) 
BlockLev <-   summarize(dat2, Acc = mean(Accuracy), Count = n())
dat3 <- group_by(dat1, Subject)
SubLev <- summarise(dat3, Acc = mean(Accuracy), Count = n())
#######################Removal##########################                            
#Removing subs with 0% overall accuracy.
Tot0 <- filter(SubLev, Acc == 0)
Sublist1 <- Tot0$Subject
BlockLev_rem1 <- BlockLev[!BlockLev$Subject %in% Sublist1,]
#Removing subs with 0% accuracy on block 1.
SubLev_1 <- filter(BlockLev, block == 0 & Acc == 0)
Sublist2 <- SubLev_1$Subject
BlockLev_rem2 <- BlockLev_rem1[!BlockLev_rem1$Subject %in% Sublist2,]
#Removing subs with 0% accuracy on block 2.
SubLev_2 <- filter(BlockLev, block == 1 & Acc == 0)
Sublist3 <- SubLev_2$Subject
BlockLev_rem3 <- BlockLev_rem2[!BlockLev_rem2$Subject %in% Sublist3,]
#Removing subs with 0% accuracy on block 3.
SubLev_3 <- filter(BlockLev, block == 2 & Acc == 0)
Sublist4 <- SubLev_3$Subject
BlockLev_rem4 <- BlockLev_rem3[!BlockLev_rem3$Subject %in% Sublist4,]
################Getting the sublist. This was the entire point##############.
Sublist5 <- unique(BlockLev_rem4$Subject)
SS_rem2 <- SS_rem2[SS_rem2$Subject %in% Sublist5,]

################Removing 2 subs who are missing trials. See Python script.##############.
badSubsTrial = c(120, 327)
SS_rem2 =SS_rem2[!SS_rem2$Subject %in% badSubsTrial,]

################Winsorizing SSRT###################
Above <- SS_rem2[SS_rem2$SSRT_Integ > mean(SS_rem2$SSRT_Integ) + (sd(SS_rem2$SSRT_Integ) * 3),]
Below <- SS_rem2[SS_rem2$SSRT_Integ < mean(SS_rem2$SSRT_Integ) - (sd(SS_rem2$SSRT_Integ) * 3),]
SS_rem2$SSRT_Integ[SS_rem2$SSRT_Integ < mean(SS_rem2$SSRT_Integ, na.rm=TRUE) - (3 * sd(SS_rem2$SSRT_Integ, na.rm=TRUE))] <- mean(SS_rem2$SSRT_Integ, na.rm=TRUE) - (3 * sd(SS_rem2$SSRT_Integ, na.rm=TRUE))
SS_rem2$SSRT_Integ[SS_rem2$SSRT_Integ > mean(SS_rem2$SSRT_Integ, na.rm=TRUE) + (3 * sd(SS_rem2$SSRT_Integ, na.rm=TRUE))] <- mean(SS_rem2$SSRT_Integ, na.rm=TRUE) + (3 * sd(SS_rem2$SSRT_Integ, na.rm=TRUE))
hist(SS_rem2$SSRT_Integ)

#Log transforming and Inverting SSRt_Integ. Actually, it doesn't need to be transformed.
#SS_rem2 <- cbind(SS_rem2, log(SS_rem2$SSRT_Integ))
hist(SS_rem2$SSRT_Integ)
summary(SS_rem2$SSRT_Integ)
sd(SS_rem2$SSRT_Integ)
#hist(SS_rem2$`log(SS_rem2$SSRT_Integ)`)
SS_rem2$SSRT_Integ_rev <- max(SS_rem2$SSRT_Integ) + min(SS_rem2$SSRT_Integ) - SS_rem2$SSRT_Integ
hist(SS_rem2$SSRT_Integ_rev)
summary(SS_rem2$SSRT_Integ_rev)
sd(SS_rem2$SSRT_Integ_rev)


   
#####################Exporting########################
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Stop")
write.table(SS_rem2, "Stop.txt", sep = "\t", row.names = F)
#END#

#####################Exporting for reliability########################
Sublist <- unique(SS_rem2$Subject)
Stop_Rel <- Stop[Stop$Subject %in% Sublist,]
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/New Analyses/Reliability")
write.table(Stop_Rel, "Stop_rel.txt", sep = "\t", row.names = F)
#END#

##############################Internal Reliability##########################################
#Select only the good subjects.
Sublist <- unique(SS_rem2$Subject)
Stop_Rel <- Stop[Stop$Subject %in% Sublist,]
sort(unique(Stop_Rel$Subject))
#############Accuracy on Stop trials################
#Adding a new trial variable without missing trials in order to convert to wide.
Stop_Rel <- Stop_Rel[order(Stop_Rel$Subject, Stop_Rel$block),]
for (i in unique(Stop_Rel$Subject)){
  Stop_Rel$TrialNew[Stop_Rel$Subject == i] <- (rep(1:length(Stop_Rel$Trial)))
}
#Get incongruent trial number for each subject and look at the max.
TrialCount <- ddply(Stop_Rel, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
Freq <- summarise(group_by(Stop_Rel, by = TrialNew), Freq = length(Subject))
#Removing subject 1. For some reason the TrialNew code isn't working on them.
Stop_Rel <- Stop_Rel[Stop_Rel$Subject != 1,]
Stop_Rel <- Stop_Rel[Stop_Rel$Subject != 120,]
Stop_Rel <- Stop_Rel[Stop_Rel$Subject != 327,]
TrialCount <- ddply(Stop_Rel, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
#Going wide.
AlphaReady <- dcast(Stop_Rel, Subject ~ TrialNew, value.var = "Accuracy")
dim(AlphaReady)
#Need a dataset with only the columns of interest. So removing "Subject".
AlphaReady <- AlphaReady[,c(-1)]
#########Calculating Cronbach's Alpha###########;
require(psych)
alpha(AlphaReady)
alpha(AlphaReady)$total
alpha(AlphaReady)$total$std.alpha 
#Items in the first block are inversely correlated with the rest. Some subs appear to be incorrect on the entire first block.
ddply(Stop_Rel, ~ c(block), summarise, MeanAcc = mean(Accuracy))
#Trying to pipe it.
Stop_Rel %>% group_by(block) %>% summarise(Mean = mean(Accuracy))
#No evidence here thta block one has lower accuracy.

###############Removing block 1################
#Select only the good subjects.
Sublist <- unique(SS_rem2$Subject)
Stop_Rel <- Stop[Stop$Subject %in% Sublist,]
sort(unique(Stop_Rel$Subject))
#Adding a new trial variable without missing trials in order to convert to wide.
Stop_Rel <- Stop_Rel[Stop_Rel$block != 0,]
Stop_Rel <- Stop_Rel[order(Stop_Rel$Subject, Stop_Rel$block),]
for (i in unique(Stop_Rel$Subject)){
  Stop_Rel$TrialNew[Stop_Rel$Subject == i] <- (rep(1:length(Stop_Rel$Trial)))
}
#Get incongruent trial number for each subject and look at the max.
TrialCount <- ddply(Stop_Rel, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
Freq <- summarise(group_by(Stop_Rel, by = TrialNew), Freq = length(Subject))
#Going wide.
AlphaReady <- dcast(Stop_Rel, Subject ~ TrialNew, value.var = "Accuracy")
dim(AlphaReady)
#Need a dataset with only the columns of interest. So removing "Subject".
AlphaReady <- AlphaReady[,c(-1)]
#########Calculating Cronbach's Alpha###########;
require(psych)
alpha(AlphaReady)
alpha(AlphaReady)$total
alpha(AlphaReady)$total$std.alpha 

##########Retaining only block 1############
#Select only the good subjects.
Sublist <- unique(SS_rem2$Subject)
Stop_Rel <- Stop[Stop$Subject %in% Sublist,]
sort(unique(Stop_Rel$Subject))
#Adding a new trial variable without missing trials in order to convert to wide.
Stop_Rel <- Stop_Rel[Stop_Rel$block == 0,]
Stop_Rel <- Stop_Rel[order(Stop_Rel$Subject, Stop_Rel$block),]
for (i in unique(Stop_Rel$Subject)){
  Stop_Rel$TrialNew[Stop_Rel$Subject == i] <- (rep(1:length(Stop_Rel$Trial)))
}
#Get incongruent trial number for each subject and look at the max.
TrialCount <- ddply(Stop_Rel, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
Freq <- summarise(group_by(Stop_Rel, by = TrialNew), Freq = length(Subject))
AlphaReady <- AlphaReady[,c(-1)]
#Going wide.
AlphaReady <- dcast(Stop_Rel, Subject ~ TrialNew, value.var = "Accuracy")
dim(AlphaReady)
#Need a dataset with only the columns of interest. So removing "Subject".
AlphaReady <- AlphaReady[,c(-1)]
#########Calculating Cronbach's Alpha###########;
require(psych)
alpha(AlphaReady)
alpha(AlphaReady)$total
alpha(AlphaReady)$total$std.alpha 


##################SSD######################
AlphaReadySSD <- dcast(Stop_Rel, Subject ~ TrialNew, value.var = "ssd")
dim(AlphaReadySSD)
#Need a dataset with only the columns of interest. So removing "Subject".
AlphaReadySSD <- AlphaReadySSD[,c(-1)]
#########Calculating Cronbach's Alpha###########;
alpha(AlphaReadySSD)
alpha(AlphaReadySSD)$total$std.alpha 


##############Accuracy on NoSignal trials##########
setwd("C:/Users/cdvrmd/Box Sync/Bruce Projects/Dissertation/Data/Tasks/Stop Signal/Output_all_Both")
Go <- read.delim(file = "SS_AllSubs_Go.txt", header = T, sep = "\t")
Go_Rel <- Go[Go$Subject %in% Sublist,]
sort(unique(Go_Rel$Subject))
#Adding a new trial variable without missing trials in order to convert to wide.
Go_Rel <- Go_Rel[order(Go_Rel$Subject, Go_Rel$block),]
for (i in unique(Stop_Rel$Subject)){
  Go_Rel$TrialNew[Go_Rel$Subject == i] <- (rep(1:length(Go_Rel$Trial)))
}
#Get incongruent trial number for each subject and look at the max.
TrialCount <- ddply(Go_Rel, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
Freq <- summarise(group_by(Go_Rel, by = TrialNew), Freq = length(Subject))
#Removing subject 1. For some reason the TrialNew code isn't working on them.
Go_Rel <- Go_Rel[Go_Rel$Subject != 1,]
Go_Rel <- Go_Rel[Go_Rel$Subject != 2,]
TrialCount <- ddply(Go_Rel, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
#Going wide.
AlphaReady <- dcast(Go_Rel, Subject ~ TrialNew, value.var = "Accuracy")
dim(AlphaReady)
#Need a dataset with only the columns of interest. So removing "Subject".
AlphaReady <- AlphaReady[,c(-1,-146)]
#########Calculating Cronbach's Alpha###########;
require(psych)
alpha(AlphaReady)
alpha(AlphaReady)$total
alpha(AlphaReady)$total$std.alpha 








# #########Other attempts at getting the data to the Subject level. I could of just used the command that I used for the sequential ERP study######3.
# #This attempt would have worked if the numver of blocks differed for each subject. Would have had to do it manually.
# SSRTdat <- as.data.frame(rep(unique(Alldat$Subject), each = 3))
# colnames(SSRTdat) <- c("Subject")
# SSRTdat$block <- rep(c(0,1,2), length(unique(SSRTdat$Subject)))
# SSRTdat <- SSRTdat[SSRTdat$Subject != 3 | SSRTdat$block != 2,]
# SSRTdat <- SSRTdat[SSRTdat$Subject != 7 | SSRTdat$block != 0,]
# SSRTdat <- SSRTdat[SSRTdat$Subject != 20 | SSRTdat$block != 0,]
# SSRTdat <- SSRTdat[SSRTdat$Subject != 29 | SSRTdat$block != 0,]
# SSRTdat <- SSRTdat[SSRTdat$Subject != 43 | SSRTdat$block != 0,]
# SSRTdat <- SSRTdat[SSRTdat$Subject != 44 | SSRTdat$block != 1,]
# SSRTdat <- SSRTdat[SSRTdat$Subject != 44 | SSRTdat$block != 2,]
# for (i in unique(Alldat$Subject)){
#   for (j in unique(Alldat$block)){
#     SSRTdat$SSRT[SSRTdat$Subject == i & SSRTdat$block ==j] <- Alldat$SSRT[Alldat$Subject == i & Alldat$block == j]
#   }
# }
# #Attempt using 'rep'.
# AlldatMelt <- melt(SSRT,  id.vars = c("Subject", "block"))
# head(AlldatMelt)
# for (i in unique(AlldatMelt$Subject)){
#     AlldatMelt$Block[AlldatMelt$Subject== i] <- rep(1:length(unique(AlldatMelt$value)))
# }
# #####################################################################################
# ######This is a number of attempts to create the index or bypass the need for one.###
# #There is a problem with this approach. For the trial loop, it uses the order of the values it selects for the first subject. Since the trial orders
# #differs for each sub, the index won't be sequential.
# 
# for (i in unique(Alldat$Subject)){
#   for (j in unique(Alldat$block)){
#     l <- 0
#     for (k in unique(Alldat$trial)){
#       l <- l + 1
# Alldat$Index[Alldat$Subject == i & Alldat$block == j & Alldat$trial == k] <- l
#     }
#   }
# }
# 
# #Testing above code.
# for (i in unique(Alldat$Subject)){
#   
#   Sample <- Alldat[Alldat$Subject == 1,]
#   for (j in unique(Alldat$block)){
#     #Sample <- Alldat[Alldat$Subject == 1 & Alldat$block == 0,]
#     l <- 0
#     for (k in 1:length(Sample$trial)){
#       l <- l + 1
#       Sample$Index[Sample$Subject == 1 & Sample$block == j & Sample$trial[k]] <- l
#     }
#   }
# }
# 
# #Trying to use an interative loop to grab the rt at TrialNum. There is the problem since TrialNum has the target value for every row.
# #sample of code below.
# l <- 0
# Sample <- Alldat[Alldat$Subject == 1 & Alldat$block == 0,]
# for (k in unique(Sample$trial)){
#   l
#   while (l < Sample$TrialNum) {
#     l <- l + 1
#   }
#   l
#     Alldat$nthRT[Alldat$Subject == i & Alldat$block == j & Alldat$trial == k] <- Alldat$rt[Alldat$Subject == i & Alldat$block == j & Alldat$TrialNum == l]
# }
# 
# 
# 
# for (i in unique(Alldat$Subject)){
#   for (j in unique(Alldat$block)){
#     l <- 0
# 
#       while (l < Alldat$TrialNum) {
#         l <- l + 1
#       }
#       Alldat$nthRT[Alldat$Subject == i & Alldat$block == j ] <- Alldat$rt[Alldat$Subject == i & Alldat$block == j & Alldat$TrialNum == l]
#     }
#   }
