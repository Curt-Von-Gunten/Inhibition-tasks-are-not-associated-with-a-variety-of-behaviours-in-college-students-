library(MplusAutomation)

####### A) Setting working directory ####### 
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Dissertation/Manuscript/For Publication/EJoP/Revision/SEM/Automation")

####### B) Creating Mplus INP files ####### 
createModels(templatefile="Master Structural Model_v2.inp")

####### C) Running Mplus INP files ####### 
runModels(target = paste0(getwd(),"/Output"), 
          recursive=TRUE,
          showOutput=FALSE,
          replaceOutfile="modifiedDate")

####### D) Reading the the Mplus OUT files ####### 
ReadModels <- readModels(target = paste0(getwd(), "/Output"))

####### E) Extracting summary and model fit statistics #######
library(plyr)
library(tibble)
fitSummary <- as_tibble(do.call("rbind.fill", sapply(ReadModels, "[", "summaries")))
#View(fitSummary)

#######  F) Extracting parameter statistics #######
paramSummary <- sapply(sapply(ReadModels, 
                                      "[", "parameters"), 
                               "[", "stdyx.standardized")

####### G) Tabulating all predictor associations with the outcomes #######
params = c(3,6)
variables = c(9:14)
allPred = c()
for (outcome in 1:length(paramSummary)){
  for (variable in variables){
    for (parameter in params){
      allPred = c(allPred, paramSummary[[outcome]][variable, parameter]) #Dfs within a list so the double brackets grab the Df defined by the outcome name and the other two arguments specify the desired rows and columns.
    }}}

allPred_df <- data.frame(matrix(unlist(allPred), nrow=28, byrow=TRUE))
outcomeNames = fitSummary['Title']
names(outcomeNames) = c("Outcome")
allPred_df$Outcome = outcomeNames
allPred_df = allPred_df[,c(13,1:12)]
names(allPred_df) = c("Outcome", "Inhib(est)", "Inhib(p)", "SC(est)", "SC(p)", 
                       "Sex(est)", "Sex(p)", "SES(est)", "SES(p)", 
                       "Raven(est)", "Raven(p)", "SocDes(est)", "SocDes(p)")

####### H) Calculating and tabulating mean coef and number of significant pvalues for each predictor across all 28 outcomes #######
allPred_df = allPred_df[-c(25),] #Removing SexRisk.

means = c()
mins = c()
maxes = c()
for (coef in seq(2,12,2)){
  tempMean = mean(allPred_df[,c(coef)])
  tempmin = min(allPred_df[,c(coef)])
  tempmax = max(allPred_df[,c(coef)])
  means = c(means, tempMean)
  mins = c(mins, tempmin)
  maxes = c(maxes, tempmax)
}

counts = c()
for (ps in seq(3,13,2)){
  tempCount = count(allPred_df[,c(ps)] <= .05)[2][2,1]
  counts = c(counts, tempCount)
}
counts

summaries = rbind(means,mins,maxes,counts)
summaries_df = data.frame(summaries)
names(summaries_df) = c("Inhib", "SC", "Sex", "SES", "Raven", "SocDes") 

####### I) Outputting DFs to txt files #######
write.table(x=allPred_df[,-1], file='AllPred_Corr.txt',sep='\t',row.names=F)
write.table(x=summaries_df, file='PredSummaries_Corr.txt',sep='\t',row.names=F)