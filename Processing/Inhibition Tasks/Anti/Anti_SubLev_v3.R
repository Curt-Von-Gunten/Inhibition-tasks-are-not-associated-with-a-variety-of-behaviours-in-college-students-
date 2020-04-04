
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Data/Tasks/Antisaccade")
Anti  = read.csv("Anti_Both.csv")
dim(Anti)

#Removing columns.
#(Note: R won't show all of the columns in the GUI)
head(Anti)
Anti <- Anti[,c("Subject", "Trial", "Mask.ACC", "Mask2.ACC", "Mask.RT", "fixDur", "Procedure.Block.")]
#Other method using integers.
#Anti <- Anti[,c(2,17,21,23,31,75,84),]

#Remove practice.
unique(Anti$Procedure.Block.)
Anti <- Anti[Anti$Procedure.Block. == "Anti1Proc" | Anti$Procedure.Block. == "Anti2Proc" |  Anti$Procedure.Block. == "ProBlock",]
Anti$Procedure.Block. <- as.character(Anti$Procedure.Block.)
unique(Anti$Procedure.Block.)

#Renaming antisaccade blocks to a single name.
Anti$Procedure.Block.[Anti$Procedure.Block. == "Anti1Proc"] <- "AntiBlock" 
Anti$Procedure.Block.[Anti$Procedure.Block. == "Anti2Proc"] <- "AntiBlock"
unique(Anti$Procedure.Block.)
unique(Anti$Mask.ACC)
sort(unique(Anti$Subject))

#Combining the two Acc coloumns.
#This doesn't work due to missing values.
  #Anti$Acc <- Anti$Mask.ACC + Anti$Mask2.ACC
#This method doesn't work.
  #if (Anti$Procedure.Block. == "ProBlock") Anti$Acc <- Anti$Mask2.ACC else Anti$Acc <- Anti$Mask.ACC
#First method.
Anti$ACC[Anti$Procedure.Block. == "ProBlock"] <- Anti$Mask2.ACC[Anti$Procedure.Block. == "ProBlock"]
Anti$ACC[Anti$Procedure.Block. != "ProBlock"] <- Anti$Mask.ACC[Anti$Procedure.Block. != "ProBlock"] 
#Second method.
  #Anti$Acc <- rowSums(Anti[,c("Mask.ACC","Mask2.ACC")], na.rm = TRUE

##############################Converting to Sub level.##########################################
require(dplyr)
attach(Anti)
dat1 <- select(Anti, Subject, Procedure.Block., ACC)
dat2 <- group_by(dat1, Subject, Procedure.Block.)
(SubLev <- summarise(dat2, ACC = mean(ACC)))
dim(SubLev)
length(unique(SubLev$Subject))
#Converting to wide.
require(reshape2)
SubLevWide <- dcast(SubLev, Subject ~ Procedure.Block., value.var = "ACC")
length(unique(SubLevWide$Subject))


######################Renaming Variables###########################
colnames(SubLevWide) <- c("Subject", "Anti_Acc", "Pro_Acc")


######################Histograms and Removal###########################
hist(SubLevWide$Anti_Acc)
hist(SubLevWide$Pro_Acc)
Num_Removed <- SubLevWide[SubLevWide$Pro_Acc < .80,]
SubLevWide_rem <- SubLevWide[!SubLevWide$Pro_Acc < .80,]
hist(SubLevWide_rem$Anti_Acc)
hist(SubLevWide_rem$Pro_Acc)

Above <- SubLevWide_rem[SubLevWide_rem$Anti_Acc > mean(SubLevWide_rem$Anti_Acc) + (sd(SubLevWide_rem$Anti_Acc) * 3),]
Below <- SubLevWide_rem[SubLevWide_rem$Anti_Acc < mean(SubLevWide_rem$Anti_Acc) - (sd(SubLevWide_rem$Anti_Acc) * 3),]
SubLevWide_rem$Anti_Acc[SubLevWide_rem$Anti_Acc < mean(SubLevWide_rem$Anti_Acc, na.rm=TRUE) - (3 * sd(SubLevWide_rem$Anti_Acc, na.rm=TRUE))] <- mean(SubLevWide_rem$Anti_Acc, na.rm=TRUE) - (3 * sd(SubLevWide_rem$Anti_Acc, na.rm=TRUE))
SubLevWide_rem$Anti_Acc[SubLevWide_rem$Anti_Acc > mean(SubLevWide_rem$Anti_Acc, na.rm=TRUE) + (3 * sd(SubLevWide_rem$Anti_Acc, na.rm=TRUE))] <- mean(SubLevWide_rem$Anti_Acc, na.rm=TRUE) + (3 * sd(SubLevWide_rem$Anti_Acc, na.rm=TRUE))
#Note, no ps are above or below the 3 SD threshhold.


###############################Export#########################
setwd("C:/Users/cdvrmd/Box Sync/Bruce Projects/Dissertation/Data/Tasks")
write.table(SubLevWide_rem, "Anti.txt", sep = "\t", row.names = F)





##############################Internal Reliability##########################################
#Select only the good subjects.
Sublist <- SubLevWide_rem$Subject
Anti_Rel <- Anti[Anti$Subject %in% Sublist,]
sort(unique(Anti_Rel$Subject))
###############################Export for Monte Carlo#########################
#setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Simulation Project")
#write.table(SubLevWide_rem, "Anti.txt", sep = "\t", row.names = F)
#############Incongruent Trials################
#Remove Pro trials.
Anti_Incong <- Anti_Rel[Anti_Rel$Procedure.Block. == "AntiBlock",]
#Adding a new trial variable without missing trials in order to convert to wide.
Anti_Incong <- Anti_Incong[order(Anti_Incong$Subject),]
for (i in unique(Anti_Incong$Subject)){
  Anti_Incong$TrialNew[Anti_Incong$Subject == i] <- (rep(1:length(Anti_Incong$Trial)))
}
#Get incongruent trial number for each subject and look at the max..
require(plyr)
TrialCount <- ddply(Anti_Incong, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
#Going wide.
AlphaReady <- dcast(Anti_Incong, Subject ~ TrialNew, value.var = "ACC")
dim(AlphaReady)
#Need a dataset with only the columns of interest. So removing "Subject".
AlphaReady <- AlphaReady[,c(-1)]
###############################Export for Python reliability#########################
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/JoP/Data & code")
write.table(AlphaReady, "Anti_Rel.txt", sep = "\t", row.names = F)
#########Calculating Cronbach's Alpha###########;
require(psych)
alpha(AlphaReady)
alpha(AlphaReady)$total
alpha(AlphaReady)$total$std.alpha 


#############Congruent Trials################
#Remove Anti trials.
Pro_Incong <- Anti_Rel[Anti_Rel$Procedure.Block. == "ProBlock",]
#Adding a new trial variable without missing trials in order to convert to wide.
Pro_Incong <- Pro_Incong[order(Pro_Incong$Subject),]
for (i in unique(Pro_Incong$Subject)){
  Pro_Incong$TrialNew[Pro_Incong$Subject == i] <- (rep(1:length(Pro_Incong$Trial)))
}
#Get incongruent trial number for each subject and look at the max..
require(plyr)
TrialCount <- ddply(Pro_Incong, ~Subject, summarise, MaxTrial = max(TrialNew))
min(TrialCount$MaxTrial)
sort(TrialCount$MaxTrial)
#Going wide.
AlphaReady <- dcast(Pro_Incong, Subject ~ TrialNew, value.var = "ACC")
dim(AlphaReady)
#Need a dataset with only the columns of interest. So removing "Subject".
AlphaReady <- AlphaReady[,c(-1)]
#########Calculating Cronbach's Alpha###########;
require(psych)
alpha(AlphaReady)
alpha(AlphaReady)$total
alpha(AlphaReady)$total$std.alpha 
