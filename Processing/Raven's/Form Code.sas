
PROC IMPORT OUT= WORK.Raven
            DATAFILE= "C:\Users\Curt\Box Sync\Bruce Projects\Dissertation\Data\Raven's Standard Progressive Matrices\Raven Standard Progressive Matrices_March 22, 2018.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

DATA Raven_Form;
SET Raven;

IF RavenRespD1  = 3 THEN RavenScoreD1 = 1;
IF RavenRespD2  = 4 THEN RavenScoreD2 = 1;
IF RavenRespD3  = 3 THEN RavenScoreD3 = 1;
IF RavenRespD4  = 7 THEN RavenScoreD4 = 1;
IF RavenRespD5  = 8 THEN RavenScoreD5 = 1;
IF RavenRespD6  = 6 THEN RavenScoreD6 = 1;
IF RavenRespD7  = 5 THEN RavenScoreD7 = 1;
IF RavenRespD8  = 4 THEN RavenScoreD8 = 1;
IF RavenRespD9  = 1 THEN RavenScoreD9 = 1;
IF RavenRespD10 = 2 THEN RavenScoreD10 = 1;
IF RavenRespD11 = 5 THEN RavenScoreD11 = 1;
IF RavenRespD12 = 6 THEN RavenScoreD12 = 1;

IF RavenRespE1  = 7 THEN RavenScoreE1 = 1;
IF RavenRespE2  = 6 THEN RavenScoreE2 = 1;
IF RavenRespE3  = 8 THEN RavenScoreE3 = 1;
IF RavenRespE4  = 2 THEN RavenScoreE4 = 1;
IF RavenRespE5  = 1 THEN RavenScoreE5 = 1;
IF RavenRespE6  = 5 THEN RavenScoreE6 = 1;
IF RavenRespE7  = 1 THEN RavenScoreE7 = 1;
IF RavenRespE8  = 6 THEN RavenScoreE8 = 1;
IF RavenRespE9  = 3 THEN RavenScoreE9 = 1;
IF RavenRespE10 = 2 THEN RavenScoreE10 = 1;
IF RavenRespE11 = 4 THEN RavenScoreE11 = 1;
IF RavenRespE12 = 5 THEN RavenScoreE12 = 1;

RavenScore = sum (RavenScoreD1, RavenScoreD2, RavenScoreD3, RavenScoreD4, RavenScoreD5, RavenScoreD6, RavenScoreD7,
				  RavenScoreD8, RavenScoreD9, RavenScoreD10, RavenScoreD11, RavenScoreD12,
				  RavenScoreE1, RavenScoreE2, RavenScoreE3, RavenScoreE4, RavenScoreE5, RavenScoreE6, RavenScoreE7,
				  RavenScoreE8, RavenScoreE9, RavenScoreE10, RavenScoreE11, RavenScoreE12);
RUN;
*Renaming variables;
DATA Raven_Form;
SET Raven_Form;
Mood2 = Mood2_1; 
RavenTime = RavenTimeCutoff_Page_Submit;
DROP Mood2_1 RavenTimeCutoff_Page_Submit;

IF Subject = . THEN DELETE;
IF Subject = 666 THEN DELETE;
IF Subject = 667 THEN DELETE;
IF Subject = 777 THEN DELETE;
RUN;

*Duplicates;
PROC SORT DATA = Raven_Form;
BY Subject;
RUN;
PROC FREQ DATA = Raven_Form;
 TABLES Subject / NOPRINT OUT = DupList;
RUN;
PROC PRINT DATA = DupList;
 WHERE Count > 1;
RUN;
*Correcting subject numbers based on log sheets and IP Address and Date;
*117A = 32;
*117 = 1;
*116 = 18;
DATA Raven_Form; 
SET Raven_Form;
IF Subject = 111 and IPAddress = "128.206.28.1" THEN Subject = 112;
IF Subject = 144 and IPAddress = "128.206.28.18" and RavenTime = 124.343 THEN DELETE;
IF Subject = 240 and IPAddress = "128.206.28.1" THEN  Subject = 239;
*IF Subject = 117 and StartDate = "15NOV17:13:10:00" THEN  Subject = 317;
Run;
PROC SORT DATA = Raven_Form;
BY Subject;
RUN;
PROC FREQ DATA = Raven_Form;
 TABLES Subject / NOPRINT OUT = DupList;
RUN;
PROC PRINT DATA = DupList;
 WHERE Count > 1;
RUN;

**************************Descriptives******************************;
PROC FREQ DATA = Raven_Form;
TABLE RavenScore RavenTime;
RUN;
PROC UNIVARIATE DATA = Raven_Form;
VAR RavenScore RavenTime;
HISTOGRAM RavenScore RavenTime;
RUN;
PROC CORR DATA = Raven_Form alpha nomiss;
VAR RavenScoreD1 RavenScoreD2 RavenScoreD3 RavenScoreD4 RavenScoreD5 RavenScoreD6 RavenScoreD7
				  RavenScoreD8 RavenScoreD9 RavenScoreD10 RavenScoreD11 RavenScoreD12
				  RavenScoreE1 RavenScoreE2 RavenScoreE3 RavenScoreE4 RavenScoreE5 RavenScoreE6 RavenScoreE7
				  RavenScoreE8 RavenScoreE9 RavenScoreE10 RavenScoreE11 RavenScoreE12;
RUN;
*Examining the time-score relationship;
PROC CORR DATA = Raven_Form;
VAR RavenScore RavenTime;
RUN;
PROC REG DATA = Raven_Form;
MODEL RavenScore = RavenTime/ STB;
RUN;
DATA Raven_Form (KEEP = Subject IPAddress Mood2_1 RavenTimeCutoff_Page_Submit RavenScore);
SET Raven_Form;
RUN;

****************************************************************************************************************************
*Note: Time taken and score are correlated. I can either remove people who completed very quickly,
or residualize score on time, or remove and then residualize;
*Calculating ratio score;
*I don't think standarizing makes sense, since you can't divide by 0, which will be the most frequent response. Plus it results in lots of extreme scores;
*I chose not to remove those hwo completed quickly or those with low scores. People with the lowest scores actually span the task on time;
DATA Raven_Form;
SET Raven_Form;
RavenRatio = RavenScore / RavenTime;
*IF RavenTime < 180 THEN DELETE;
RUN;
PROC UNIVARIATE DATA = Raven_Form;
VAR RavenRatio;
HISTOGRAM RavenRatio;
RUN;
PROC FREQ DATA = Raven_Form;
TABLE RavenRatio;
RUN;
*Winsorizing participant who has a ratio greater than 100;
DATA Raven_Form;
SET Raven_Form;
RavenRatio_win = RavenRatio;
IF RavenRatio_win > 0.03424441 + (0.01049226 * 3) THEN RavenRatio_win = 0.03424441 + (0.01049226 * 3);
IF RavenRatio_win < 0.03424441 - (0.01049226 * 3) THEN RavenRatio_win = 0.03424441 - (0.01049226 * 3);
RUN;
PROC UNIVARIATE DATA = Raven_Form;
VAR RavenRatio RavenRatio_win;
HISTOGRAM RavenRatio RavenRatio_win;
RUN;
PROC CORR DATA = Raven_Form;
VAR RavenRatio RavenRatio_win RavenScore RavenTime;
RUN;
PROC REG DATA = Raven_Form;
MODEL RavenScore = RavenTime/ STB;
RUN;
PROC REG DATA = Raven_Form;
MODEL RavenRatio = RavenTime/ STB;
RUN;

*Residualizing Score on Time (Note: Should I remove any Ps before doing this?);
DATA Raven_Form;
SET Raven_Form;
RavenTime_st = RavenTime;
RavenScore_st = RavenScore;
RUN;
PROC STANDARD DATA = Raven_Form MEAN = 0 STD =1
              OUT = Raven_Form;
			  VAR RavenTime_st RavenScore_st;
PROC MEANS DATA = Raven_Form;
VAR RavenTime_st RavenScore_st;
RUN;
PROC REG DATA = Raven_Form;
MODEL RavenScore_st = RavenTime_st/ STB;
OUTPUT OUT = Raven_Form
r = Raven_res;
RUN;
*For some reason, you need to run a proc to "release" the above Output dataset;
PROC SORT DATA = Raven_Form;
BY Subject;
RUN;
DATA Raven_Form (DROP = RavenTime_st RavenScore_st RavenRatio IPAddress);
SET Raven_Form;
RUN;

*Export to tab delimited;
PROC EXPORT DATA= WORK.Raven_Form_Res 
            OUTFILE= "C:\Users\cdvrmd\Box Sync\Bruce Projects\Dissertation\Data\Raven's Standard Progressive Matrices\Raven_Form.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=YES;
RUN;

/*DATA Raven_Exp;
SET Raven_Form;
IF RavenTime <= 60 THEN TimeDich = "First";
ELSE IF RavenTime <= 120 THEN TimeDich = "Second";
ELSE IF RavenTime <= 180 THEN TimeDich = "Third";
ELSE IF RavenTime <= 240 THEN TimeDich = "Fourth";
ELSE IF RavenTime <= 300 THEN TimeDich = "Fifth";
ELSE IF RavenTime <= 360 THEN TimeDich = "Sixth";
ELSE IF RavenTime <= 340 THEN TimeDich = "Seventh";
RUN; */
/*PROC MEANS DATA = Raven_Rem;
Class TimeDich;
VAR RavenScore;
RUN;*/





