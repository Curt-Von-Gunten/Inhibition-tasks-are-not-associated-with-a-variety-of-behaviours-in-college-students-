setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Stroop")
Stroop  = read.csv("Stroop_Both.csv")
dim(simon)

#Removing columns.
Stroop <- Stroop[,c(2,17,21,23,24,33,47,54),]
#Remove incorrect trials.
Stroop_cor <- Stroop[Stroop$Word.ACC == 1,]
#Remove practice trials
unique(Stroop$Procedure.Block.)
Stroop_cor <- Stroop_cor[Stroop_cor$Procedure.Block. != "pracXProc" & Stroop_cor$Procedure.Block. != "pracIncongProc",]
#Remove missing trials.
Stroop_cor <- Stroop_cor[!is.na(Stroop_cor$Procedure.Block.),]
Stroop_cor <- Stroop_cor[!is.na(Stroop_cor$Word.RT),]
#Checks.
unique(Stroop_cor$Block)
unique(Stroop_cor$condition)
unique(Stroop_cor$Procedure.Block.)
unique(Stroop_cor$Word.ACC)
sort(unique(Stroop_cor$Subject))
#Exploring RTs.
hist(Stroop_cor$Word.RT)
summary(Stroop_cor$Word.RT)


####################################Within-subjects trimming. Here we go! Hold on!######################################
require(stats)
Stroop_rem <- data.frame()
Stroop_cor$Out <- 0
for (i in (unique(Stroop_cor$Subject))) {
  for (j in (unique(Stroop_cor$condition))) {
  temp <- Stroop_cor[Stroop_cor$Subject == i & Stroop_cor$condition == j,]
  #temp$Out[((abs(temp$Word.RT - median(temp$Word.RT))) / mad(temp$Word.RT)) > 3.5] <- 1
  temp <- temp[!((abs(temp$Word.RT - median(temp$Word.RT))) / mad(temp$Word.RT)) > 2.5,]
  Stroop_rem <- rbind(Stroop_rem, temp)
  }
}

(dim(Stroop_cor)[1]  - dim(Stroop_rem)[1]) / dim(Stroop_cor)[1]  

min(Stroop_rem$Word.RT, na.rm=T)
summary(Stroop_rem$Word.RT)

#Exploring
#Removed <- Stroop_rem[Stroop_rem$Out == 1,]
#hist(Removed$Word.RT)
#summary(Removed$Word.RT)
# 3% of trials removed by 2.5 SD (3226 trials out of 98,370).
#length(Removed$Subject)
#rows <- dim(Stroop_cor)  
#rows <- rows[1]
#length(Removed$Subject) / rows
#hist(Stroop_rem$Word.RT)
#summary(Stroop_rem$Word.RT)
Subject244_rem <- Stroop[Stroop$Subject == 244,]
Subject244 <- Stroop_cor[Stroop_cor$Subject == 244,]
hist(Subject244$Word.RT)
hist(Subject244_rem$Word.RT)

Stroop_Wins <- winsorize(Stroop_cor$Word.RT, na.rm = FALSE)
require(stats)

require(robustHD)
Stroop_wins <- data.frame()
for (i in (unique(Stroop_cor$Subject))) {
  for (j in (unique(Stroop_cor$condition))) {
    temp <- Stroop_cor[Stroop_cor$Subject == i & Stroop_cor$condition == j,]
    #temp$Out[((abs(temp$Word.RT - median(temp$Word.RT))) / mad(temp$Word.RT)) > 3.5] <- 1
    temp <- winsorize(temp$Word.RT)
    Stroop_wins <- rbind(Stroop_wins, temp)
  }
}
Subject244_wins <- Stroop_wins[Stroop_wins$Subject == 244,]
Subject244 <- Stroop_cor[Stroop_cor$Subject == 244,]
hist(Subject244$Word.RT)
hist(Subject244_wins$Word.RT)

#Manual.
Stroop_wins <- data.frame()
for (i in (unique(Stroop_cor$Subject))) {
  for (j in (unique(Stroop_cor$condition))) {
    temp <- Stroop_cor[Stroop_cor$Subject == i & Stroop_cor$condition == j,]
    temp <- temp[!((abs(temp$Word.RT - mean(temp$Word.RT))) / mean(temp$Word.RT)) > 2,]
    Stroop_wins <- rbind(Stroop_wins, temp)
  }
}
Subject244_wins <- Stroop_wins[Stroop_wins$Subject == 244,]
Subject244 <- Stroop_cor[Stroop_cor$Subject == 244,]
hist(Subject244$Word.RT)
hist(Subject244_wins$Word.RT)
max(Subject244_wins$Word.RT)
max(Subject244$Word.RT)
    
    
##############################Converting to Sub level.##########################################
require(dplyr)
#attach(Stroop_rem)
dat1 <- select(Stroop_rem, Subject, Word.RT, Word.ACC, condition)
dat2 <- group_by(dat1, Subject, condition)
(SubLev <- summarise(dat2, RT = mean(Word.RT)))
dim(SubLev)
length(unique(Stroop_acc$Subject))
#Converting to wide.
require(reshape2)
SubLevWide <- dcast(SubLev, Subject ~ condition, value.var = "RT")
SubLevWide <- SubLevWide[,-4]
length(unique(SubLevWide$Subject))



################Getting Accuracy info, since I removed incorrect trials earlier. ########################
#Remove practice trials
Stroop_acc <- Stroop[Stroop$Procedure.Block. != "pracXProc" & Stroop$Procedure.Block. != "pracIncongProc",]
#Removing NA.
Stroop_acc <- Stroop_acc[!is.na(Stroop_acc$Word.ACC),]
#Checks.
unique(Stroop_acc$Block)
unique(Stroop_acc$Word.ACC)
length(unique(Stroop_acc$Subject))

#Converting to Sub Level.
#attach(Stroop_acc)
dat1 <- select(Stroop_acc, Subject, Word.RT, Word.ACC, condition)
dat2 <- group_by(dat1, Subject, condition)
(SubLev_Acc <- summarise(dat2, Acc = mean(Word.ACC)))
dim(SubLev_Acc)
#There is 1 person with 0% accuracy. I need to remove this person from the RT data above or the RT and ACC deata sets will have an uneven number of rows.
Fail <- SubLev_Acc[SubLev_Acc$Acc == 0,]
SubLevWide <- SubLevWide[!SubLevWide$Subject == 106,]
#Converting to wide.
SubLevWide_Acc <- dcast(SubLev_Acc, Subject ~ condition, value.var = "Acc")



######################Merging columns of RT and Acc into a new dataframe.###########################
Stroop_SubLev_Trim <- merge(SubLevWide, SubLevWide_Acc, by = "Subject")

colnames(Stroop_SubLev_Trim) <- c("Subject", "Stroop_RT_Cong", "Stroop_RT_Incong", "Stroop_Acc_Cong", "Stroop_Acc_Incong")
length(unique(Stroop_SubLev_Trim$Subject))
#Stroop_SubLev_Trim <- data.frame(Subject = SubLevWide$Subject, Stroop_RT_Cong = SubLevWide$Cong, Stroop_RT_Incong = SubLevWide$Incong, 
#                  Stroop_Acc_Cong = SubLevWide_Acc$Cong, Stroop_Acc_Incong = SubLevWide_Acc$Incong)



##############Export#############This is the original data I used for sublevel cleaning in SAS.
#write.table(Stroop_SubLev_Trim, "Stroop_SubLev_Trimmed.txt", sep = "\t", row.names = F)



#######################Trying to duplicate the Between-Subs Cleaning from SAS######.
#Removing subs with missing RT data.
StroopClean <- Stroop_SubLev_Trim[!is.na(Stroop_SubLev_Trim$Stroop_RT_Cong) & !is.na(Stroop_SubLev_Trim$Stroop_RT_Incong),]
hist(StroopClean$Stroop_Acc_Cong)
StroopClean2 <- StroopClean[!StroopClean$Stroop_Acc_Cong < .80,]
hist(StroopClean2$Stroop_Acc_Cong)
hist(StroopClean2$Stroop_Acc_Incong)
StroopClean3 <- StroopClean2[!StroopClean2$Stroop_Acc_Incong <= .50,]
hist(StroopClean3$Stroop_Acc_Incong)
StroopClean3 <- StroopClean3[!is.na(StroopClean3$Subject),]
test <- StroopClean3[StroopClean3$Subject == 227,]
#Making a difference score.
StroopClean3$Stroop_RT_Diff <- StroopClean3$Stroop_RT_Cong - StroopClean3$Stroop_RT_Incong
#Winsorizing at the subject level based on RT.
summary(StroopClean3$Stroop_RT_Diff)
summary(StroopClean3$Stroop_RT_Cong)
summary(StroopClean3$Stroop_RT_Incong)
hist(StroopClean3$Stroop_RT_Diff)
StroopClean3$Stroop_RT_Diff[StroopClean3$Stroop_RT_Diff < mean(StroopClean3$Stroop_RT_Diff, na.rm=TRUE) - (3 * sd(StroopClean3$Stroop_RT_Diff, na.rm=TRUE))] <- mean(StroopClean3$Stroop_RT_Diff, na.rm=TRUE) - (3 * sd(StroopClean3$Stroop_RT_Diff, na.rm=TRUE))
StroopClean3$Stroop_RT_Diff[StroopClean3$Stroop_RT_Diff > mean(StroopClean3$Stroop_RT_Diff, na.rm=TRUE) + (3 * sd(StroopClean3$Stroop_RT_Diff, na.rm=TRUE))] <- mean(StroopClean3$Stroop_RT_Diff, na.rm=TRUE) + (3 * sd(StroopClean3$Stroop_RT_Diff, na.rm=TRUE))
summary(StroopClean3$Stroop_RT_Diff)
summary(StroopClean3$Stroop_RT_Cong)
summary(StroopClean3$Stroop_RT_Incong)
hist(StroopClean3$Stroop_RT_Diff)



###############################Export#########################
write.table(StroopClean3, "Stroop_MadTrim2.5.txt", sep = "\t", row.names = F)


###############################Export for Simulation Project#########################
Sublist <- unique(StroopClean3$Subject)
Stroop_Rel <- Stroop_rem[Stroop_rem$Subject %in% Sublist,]
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/New Analyses/Reliability")
write.table(Stroop_Rel, "Stroop_rel.txt", sep = "\t", row.names = F)


#Checking hisograms of subs who are mean RT outliers.
#dat <- Stroop_SubLev_Trim[!is.na(Stroop_SubLev_Trim$Stroop_RT_Cong),]
#Max
#dat$Subject[max(dat$Stroop_RT_Cong) == dat$Stroop_RT_Cong]
#Min
#dat$Subject[min(dat$Stroop_RT_Cong) == dat$Stroop_RT_Cong]

#Sub322 <- Stroop_rem[Stroop_rem$Subject == 322,]
#Sub322_incong <- Sub322[Sub322$condition == "Incong",]
#Sub322_cong <- Sub322[Sub322$condition == "Cong",]
#hist(Sub322$Word.RT)
#mean(Sub322$Word.RT)
#hist(Sub322_incong$Word.RT)
#mean(Sub322_incong$Word.RT)
#hist(Sub322_cong$Word.RT)
#mean(Sub322_cong$Word.RT)

#Sub410 <- Stroop_rem[Stroop_rem$Subject == 410,]
#Sub410_incong <- Sub410[Sub410$condition == "Incong",]
#Sub410_cong <- Sub410[Sub410$condition == "Cong",]
#ist(Sub410$Word.RT)
#ean(Sub410$Word.RT)
#hist(Sub410_incong$Word.RT)
#mean(Sub410_incong$Word.RT)
#hist(Sub410_cong$Word.RT)
#mean(Sub410_cong$Word.RT)




##############################Internal Reliability##########################################
#Select only the good subjects.
Sublist <- unique(StroopClean3$Subject)
Stroop_Rel <- Stroop_rem[Stroop_rem$Subject %in% Sublist,]
sort(unique(Stroop_Rel$Subject))
#############Incongruent Trials################
#Remove Cong trials.
Stroop_Incong <- Stroop_Rel[Stroop_Rel$condition == "Incong",]
#Adding a new trial variable without missing trials in order to convert to wide.
Stroop_Incong <- Stroop_Incong[order(Stroop_Incong$Subject, Stroop_Incong$Block),]
for (i in unique(Stroop_Incong$Subject)){
  Stroop_Incong$TrialNew[Stroop_Incong$Subject == i] <- (rep(1:length(Stroop_Incong$Trial)))
}
#Get incongruent trial number for each subject and look at the max..
TrialCount <- ddply(Stroop_Incong, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
Freq <- summarise(group_by(Stroop_Incong, by = TrialNew), Freq = length(Subject))
#Removing trials less than 140.
#Lowering this to make it positive definite still results in 96%.
Stroop_Incong <- Stroop_Incong[Stroop_Incong$TrialNew <= 140,]
summarise(group_by(Stroop_Incong, by = TrialNew), Freq = length(Subject))
#Going wide.
AlphaReady <- dcast(Stroop_Incong, Subject ~ TrialNew, value.var = "Word.RT")
dim(AlphaReady)
#Need a dataset with only the columns of interest. So removing "Subject".
AlphaReady <- AlphaReady[,c(-1)]
#########Calculating Cronbach's Alpha###########;
require(psych)
alpha(AlphaReady)
alpha(AlphaReady)$total
alpha(AlphaReady)$total$std.alpha 

#############Congruent Trials################
#Remove Incong trials.
Stroop_Cong <- Stroop_Rel[Stroop_Rel$condition == "Cong",]
#Adding a new trial variable without missing trials in order to convert to wide.
Stroop_Cong <- Stroop_Cong[order(Stroop_Cong$Subject, Stroop_Cong$Block),]
for (i in unique(Stroop_Cong$Subject)){
  Stroop_Cong$TrialNew[Stroop_Cong$Subject == i] <- (rep(1:length(Stroop_Cong$Trial)))
}
#Get incongruent trial number for each subject and look at the max..
TrialCount <- ddply(Stroop_Cong, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
Freq <- summarise(group_by(Stroop_Cong, by = TrialNew), Freq = length(Subject))
#Removing trials less than 140.
Stroop_Cong <- Stroop_Cong[Stroop_Cong$TrialNew <= 140,]
summarise(group_by(Stroop_Cong, by = TrialNew), Freq = length(Subject))
#Going wide.
AlphaReady <- dcast(Stroop_Cong, Subject ~ TrialNew, value.var = "Word.RT")
dim(AlphaReady)
#Need a dataset with only the columns of interest. So removing "Subject".
AlphaReady <- AlphaReady[,c(-1)]
#########Calculating Cronbach's Alpha###########;
require(psych)
alpha(AlphaReady)
alpha(AlphaReady)$total
alpha(AlphaReady)$total$std.alpha 
