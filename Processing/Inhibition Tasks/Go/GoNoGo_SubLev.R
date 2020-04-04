
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Data/Tasks/Go_NoGo")
Go  = read.csv("Go_NoGo_Both.csv")
dim(Go)

#Removing columns.
Go <- Go[,c(2,17,21,23,24,25,31,38,40,50),]
#Remove practice.
unique(Go$Procedure.Block.)
Go <- Go[Go$Procedure.Block. != "BlockPrac",]
unique(Go$Procedure.Block.)
unique(Go$TrialType)
unique(Go$response.ACC)
sort(unique(Go$Subject))


##############################Converting to Sub level.##########################################
require(dplyr)
attach(Go)
dat1 <- select(Go, Subject, TrialType, response.ACC)
dat2 <- group_by(dat1, Subject, TrialType)
(SubLev <- summarise(dat2, ACC = mean(response.ACC)))
dim(SubLev)
length(unique(SubLev$Subject))
#Converting to wide.
require(reshape2)
SubLevWide <- dcast(SubLev, Subject ~ TrialType, value.var = "ACC")
length(unique(SubLevWide$Subject))


######################Renaming Variables###########################
colnames(SubLevWide) <- c("Subject", "Go_Acc", "NoGo_Acc")

######################Histograms and Removal###########################
hist(SubLevWide$Go_Acc)
hist(SubLevWide$NoGo_Acc)
Num_Removed <- SubLevWide[SubLevWide$Go_Acc < .80,]
SubLevWide_rem <- SubLevWide[!SubLevWide$Go_Acc < .80,]
hist(SubLevWide_rem$Go_Acc)
hist(SubLevWide_rem$NoGo_Acc)
#When calculating internal reliability I found a participant with only four trials. Removing.
SubLevWide_rem <- SubLevWide_rem[!SubLevWide_rem$Subject == 214,]

Above <- SubLevWide_rem[SubLevWide_rem$NoGo_Acc > mean(SubLevWide_rem$NoGo_Acc) + (sd(SubLevWide_rem$NoGo_Acc) * 3),]
Below <- SubLevWide_rem[SubLevWide_rem$NoGo_Acc < mean(SubLevWide_rem$NoGo_Acc) - (sd(SubLevWide_rem$NoGo_Acc) * 3),]
SubLevWide_rem$NoGo_Acc[SubLevWide_rem$NoGo_Acc < mean(SubLevWide_rem$NoGo_Acc, na.rm=TRUE) - (3 * sd(SubLevWide_rem$NoGo_Acc, na.rm=TRUE))] <- mean(SubLevWide_rem$NoGo_Acc, na.rm=TRUE) - (3 * sd(SubLevWide_rem$NoGo_Acc, na.rm=TRUE))
SubLevWide_rem$NoGo_Acc[SubLevWide_rem$NoGo_Acc > mean(SubLevWide_rem$NoGo_Acc, na.rm=TRUE) + (3 * sd(SubLevWide_rem$NoGo_Acc, na.rm=TRUE))] <- mean(SubLevWide_rem$NoGo_Acc, na.rm=TRUE) + (3 * sd(SubLevWide_rem$NoGo_Acc, na.rm=TRUE))
#Note that there are 0 Ps beyond the 3SD threshhold.


###############################Export#########################
setwd("C:/Users/cdvrmd/Box Sync/Bruce Projects/Dissertation/Data/Tasks")
write.table(SubLevWide_rem, "Go.txt", sep = "\t", row.names = F)