
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/Task Reprocessing/Simon")
simon  = read.csv("Simon_Both.csv")
dim(simon)


simon <- simon[,c(-1,-3:-18,-20:-24,-26,-28:-33,-35:-56),]

#Remove incorrect trials.
simon_cor <- simon[simon$Delay.ACC == 1,]
#Remove practice trials
simon_cor <- simon_cor[!simon_cor$Block == 1,]
#Remove missing trials.
simon_cor <- simon_cor[!is.na(simon_cor$Delay.RT),]
#Checks.
unique(simon_cor$Block)
unique(simon_cor$Delay.ACC)
sort(unique(simon_cor$Subject))



####################################Within-subjects trimming. Here we go! Hold on!######################################
#First I'm going to check ranges of RTs.
require(stats)
simon_rem <- data.frame()
simon_cor$Out <- 0
for (i in (unique(simon_cor$Subject))) {
  for (j in (unique(simon_cor$TrialCond))) {
  temp <- simon_cor[simon_cor$Subject == i & simon_cor$TrialCond == j,]
  temp <- temp[!((abs(temp$Delay.RT - median(temp$Delay.RT))) / mad(temp$Delay.RT)) > 3.5,]
  #temp$Out[((abs(temp$Delay.RT - median(temp$Delay.RT))) / mad(temp$Delay.RT)) > 2.5] <- 1
  simon_rem <- rbind(simon_rem, temp)
  }
}

#Checking.
summary(simon_rem$Delay.RT)
summary(simon_cor$Delay.RT)
min(simon_rem$Delay.RT[simon_rem$Subject == 2])
min(simon_cor$Delay.RT[simon_rem$Subject == 2])
max(simon_rem$Delay.RT[simon_rem$Subject == 2])
max(simon_cor$Delay.RT[simon_rem$Subject == 2])

#Percentage removed (.033% for 2.5)..
(length(simon_cor$Subject) - length(simon_rem$Subject)) / length(simon_cor$Subject)

#########I think I discovered that the loop above for removed trials is corrupt, since it runs after the original removal.
#Removed <- simon_rem[simon_rem$Out == 1,]
#hist(Removed$Delay.RT)
#summary(Removed$Delay.RT)
# .7% of trials removed by 2.5 SD (837 trials out of 112,657) and .2% removed with 3 SD (218 trials out of 112,657).
#length(Removed$Subject)
#rows <- dim(simon_cor)  
#rows <- rows[1]
#length(Removed$Subject) / rows
#hist(simon_rem$Delay.RT)
#summary(simon_rem$Delay.RT)



##############################Converting to Sub level.##########################################
require(dplyr)
attach(simon_cor)
dat1 <- select(simon_cor, Subject, Delay.RT, Delay.ACC, TrialCond, Trial, Block, TrialType)
dat2 <- group_by(dat1, Subject, TrialCond)
(SubLev <- summarise(dat2, RT = mean(Delay.RT)))
dim(SubLev)

require(reshape2)
SubLevWide <- dcast(SubLev, Subject ~ TrialCond, value.var = "RT")



################Getting Accuracy info, since I removed incorrect trials earlier. ########################
#Remove practice trials
simon_acc <- simon[!simon$Block == 1,]
#Checks.
unique(simon_acc$Block)
unique(simon_acc$Delay.ACC)

#Converting to Sub Level.
attach(simon_acc)
dat1 <- select(simon_acc, Subject, Delay.RT, Delay.ACC, TrialCond, Trial, Block, TrialType)
dat2 <- group_by(dat1, Subject, TrialCond)
(SubLev_Acc <- summarise(dat2, Acc = mean(Delay.ACC)))
dim(SubLev_Acc)
SubLevWide_Acc <- dcast(SubLev_Acc, Subject ~ TrialCond, value.var = "Acc")



######################Merging columns of RT and Acc into a new dataframe.###########################
Simon_SubLev_Trim <- merge(SubLevWide, SubLevWide_Acc, by = "Subject")

colnames(Simon_SubLev_Trim) <- c("Subject", "Simon_RT_Cong", "Simon_RT_Incong", "Simon_Acc_Cong", "Simon_Acc_Incong")
length(unique(Simon_SubLev_Trim$Subject))

#Original approach. This approachcaused a mistake in the Simon program due to offset subject values.
#Simon_SubLev_Trim <- data.frame(Subject = SubLevWide$Subject, Simon_RT_Cong = SubLevWide$cong, Simon_RT_Incong = SubLevWide$incong, 
#                  Simon_Acc_Cong = SubLevWide_Acc$cong, Simon_Acc_Incong = SubLevWide_Acc$incong)



#######################Trying to duplicate the Between-Subs Cleaning from SAS######.
#Removing subs with missing RT data.
SimonClean <- Simon_SubLev_Trim[!is.na(Simon_SubLev_Trim$Simon_RT_Cong) & !is.na(Simon_SubLev_Trim$Simon_RT_Incong),]
hist(SimonClean$Simon_Acc_Cong)
SimonClean2 <- SimonClean[!SimonClean$Simon_Acc_Cong < .60,]
hist(SimonClean2$Simon_Acc_Cong)
hist(SimonClean2$Simon_Acc_Incong)
SimonClean3 <- SimonClean2[!SimonClean2$Simon_Acc_Incong <= .20,]
hist(SimonClean3$Simon_Acc_Incong)
SimonClean3 <- SimonClean3[!is.na(SimonClean3$Subject),]
test <- SimonClean3[SimonClean3$Subject == 227,]
#Making a difference score.
SimonClean3$Simon_RT_Diff <- SimonClean3$Simon_RT_Cong - SimonClean3$Simon_RT_Incong
#Winsorizing at the subject level based on RT Diff.
summary(SimonClean3$Simon_RT_Diff)
summary(SimonClean3$Simon_RT_Cong)
summary(SimonClean3$Simon_RT_Incong)
hist(SimonClean3$Simon_RT_Diff)
Above <- SimonClean3[SimonClean3$Simon_RT_Diff > mean(SimonClean3$Simon_RT_Diff, na.rm=TRUE) + (3 * sd(SimonClean3$Simon_RT_Diff, na.rm=TRUE)),]
Below <- SimonClean3[SimonClean3$Simon_RT_Diff < mean(SimonClean3$Simon_RT_Diff, na.rm=TRUE) - (3 * sd(SimonClean3$Simon_RT_Diff, na.rm=TRUE)),]
SimonClean3$Simon_RT_Diff[SimonClean3$Simon_RT_Diff < mean(SimonClean3$Simon_RT_Diff, na.rm=TRUE) - (3 * sd(SimonClean3$Simon_RT_Diff, na.rm=TRUE))] <- mean(SimonClean3$Simon_RT_Diff, na.rm=TRUE) - (3 * sd(SimonClean3$Simon_RT_Diff, na.rm=TRUE))
SimonClean3$Simon_RT_Diff[SimonClean3$Simon_RT_Diff > mean(SimonClean3$Simon_RT_Diff, na.rm=TRUE) + (3 * sd(SimonClean3$Simon_RT_Diff, na.rm=TRUE))] <- mean(SimonClean3$Simon_RT_Diff, na.rm=TRUE) + (3 * sd(SimonClean3$Simon_RT_Diff, na.rm=TRUE))
summary(SimonClean3$Simon_RT_Diff)
summary(SimonClean3$Simon_RT_Cong)
summary(SimonClean3$Simon_RT_Incong)
hist(SimonClean3$Simon_RT_Diff)



###############################Export#########################
write.table(SimonClean3, "Simon_MadTrim3.5.txt", sep = "\t", row.names = F)


#Sub322 <- simon_rem[simon_rem$Subject == 322,]
#Sub322_incong <- Sub322[Sub322$TrialCond == "incong",]
#Sub322_cong <- Sub322[Sub322$TrialCond == "cong",]
#hist(Sub322$Delay.RT)
##st(Sub322_incong$Delay.RT)
#mean(Sub322_incong$Delay.RT)
#hist(Sub322_cong$Delay.RT)
#mean(Sub322_cong$Delay.RT)