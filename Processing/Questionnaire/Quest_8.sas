
PROC IMPORT OUT= WORK.Quest
            DATAFILE= "C:\Users\Curt\Box Sync\Bruce Projects\Dissertation\Data\Questionnaire\Questionnaire_num_All.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
PROC CONTENTS DATA = Quest;
RUN;

*********Duplicates*******;
PROC SORT DATA = Quest;
BY Subject;
RUN;
PROC FREQ DATA = Quest;
 TABLES Subject / NOPRINT OUT = DupList;
RUN;
PROC PRINT DATA = DupList;
 WHERE Count > 1;
RUN;
*Correcting subject numbers based on log sheets and IP Address;
*117A = 32;
*117 = 1;
*116 = 18;
DATA Quest; 
SET Quest;
IF Subject = 53 and IPAddress = "128.206.28.182" THEN Subject = 54;
IF Subject = 117 and Duration__in_seconds_ = 2050 THEN Subject = 317;
RUN;
PROC SORT DATA = Quest;
BY Subject;
RUN;
PROC FREQ DATA = Quest;
TABLES Subject / NOPRINT OUT = DupList;
RUN;
PROC PRINT DATA = DupList;
WHERE Count > 1;
RUN;


*Removing unneeded columns;
DATA Quest_clean;
SET Quest;
IF MISSING(Subject) THEN DELETE;
DROP StartDate EndDate Status Progress RecordedDate ResponseID RecipientLastName
	 RecipientFirstName RecipientEmail ExternalReference LocationLatitude Locationlongitude 
	 DistributionChannel UserLanguage;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Race = 1 THEN Race_cat = "white";
ELSE Race_cat = "other";
IF Sex = 2 THEN Sex = 0;
ELSE IF Sex = 1 THEN Sex = 1;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Race_cat Age Sex ReligionCat ReligionDegree PolCat PolDeg;
RUN;
PROC Freq DATA = Quest_clean;
RUN;
/*PROC MEANS DATA = Quest_clean;
VAR Age;
RUN; */

**********Lure**********;
DATA Quest_clean;
SET Quest_clean;
IF Lure1 = -99 THEN Lure1 = .; IF Lure2 = -99 THEN Lure2 = .; IF Lure3 = -99 THEN Lure3 = .; IF Lure4 = -99 THEN Lure4 = .;
IF Lure5 = -99 THEN Lure5 = .; IF Lure6 = -99 THEN Lure6 = .; IF Lure7 = -99 THEN Lure7 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Lure1 - Lure7;
RUN;
DATA Quest_clean;
SET Quest_clean;
Lure_miss = cmiss(of Lure1 - Lure7);
RUN;
PROC Freq DATA = Quest_clean;
TABLE Lure_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Lure1 NE 4 THEN Lure_Inc1 = 1; 
IF Lure2 NE 1 THEN Lure_Inc2 = 1;
IF Lure3 NE 7 THEN Lure_Inc3 = 1;
IF Lure4 NE 8 THEN Lure_Inc4 = 1;
IF Lure5 NE 2 THEN Lure_Inc5 = 1;
IF Lure6 NE 3 THEN Lure_Inc6= 1;
IF Lure7 NE 2 THEN Lure_Inc7 = 1;
Lure_Acc = sum(of Lure_Inc1 - Lure_Inc7);
IF MISSING(Lure_Acc) THEN Lure_Acc = 0;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Lure1-Lure7 Lure_Acc;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Lure_Acc > 2 THEN DELETE;
RUN; 


******************************************************;
*******************Computing Composites***************;
******************************************************;

********************************************Self-Control and Social Desireability*********************************************;
*SES;
PROC Freq DATA = Quest_clean;
TABLE SESEduFath SESEduMoth SESFamInc SESSelfRep;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF SESEduFath = 10 THEN SESEduFath = .; 
IF SESEduMoth = 10 THEN SESEduMoth = .; 
IF SESEduFath = -99 THEN SESEduFath = .; 
IF SESEduMoth = -99 THEN SESEduMoth = .;
IF SESFamInc = -99 THEN SESFamInc = .; 
IF SESSelfRep =-99 THEN SESSelfRep = .; 
RUN;
PROC Freq DATA = Quest_clean;
TABLE SESEduFath SESEduMoth SESFamInc SESSelfRep;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR SESEduFath SESEduMoth SESFamInc SESSelfRep;
HISTOGRAM SESEduFath SESEduMoth SESFamInc SESSelfRep;
RUN;
*Reliability;
PROC CORR DATA = Quest_clean ALPHA NOMISS;;
VARIABLE SESEduFath SESEduMoth SESFamInc SESSelfRep;
RUN;
PROC STANDARD DATA = Quest_clean MEAN = 0 STD =1
              OUT = Quest_clean;
			  VAR SESEduFath SESEduMoth SESFamInc SESSelfRep;
RUN;
DATA Quest_clean;
SET Quest_clean;
SES = mean(SESEduFath, SESEduMoth, SESFamInc, SESSelfRep);
SES_miss = cmiss(SESEduFath, SESEduMoth, SESFamInc, SESSelfRep);
RUN;
PROC Freq DATA = Quest_clean;
TABLE SES_Miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF SES_miss >= 3 THEN SES = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR SES;
HISTOGRAM SES;
RUN;

*UPPS_P;
DATA Quest_clean;
SET Quest_clean;
UPPS_P21 = UPPS_P121;
UPPS_P26 = UPPS_26;
RUN;
PROC Freq DATA = Quest_clean;
TABLE  UPPS_P1-UPPS_P59;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF UPPS_P1 = -99 THEN UPPS_P1 = .;   IF UPPS_P2 = -99 THEN UPPS_P2 = .;   IF UPPS_P3 = -99 THEN UPPS_P3 = .;  
IF UPPS_P4 = -99 THEN UPPS_P4 = .;   IF UPPS_P5 = -99 THEN UPPS_P5 = .;   IF UPPS_P6 = -99 THEN UPPS_P6 = .;  
IF UPPS_P7 = -99 THEN UPPS_P7 = .;   IF UPPS_P8 = -99 THEN UPPS_P8 = .;   IF UPPS_P9 = -99 THEN UPPS_P9 = .;  
IF UPPS_P10 = -99 THEN UPPS_P10 = .; IF UPPS_P11 = -99 THEN UPPS_P11 = .; IF UPPS_P12 = -99 THEN UPPS_P12 = .;
IF UPPS_P13 = -99 THEN UPPS_P13 = .; IF UPPS_P14 = -99 THEN UPPS_P14 = .; IF UPPS_P15 = -99 THEN UPPS_P15 = .;
IF UPPS_P16 = -99 THEN UPPS_P16 = .; IF UPPS_P17 = -99 THEN UPPS_P17 = .; IF UPPS_P18 = -99 THEN UPPS_P18 = .;
IF UPPS_P19 = -99 THEN UPPS_P19 = .; IF UPPS_P20 = -99 THEN UPPS_P20 = .; IF UPPS_P21 = -99 THEN UPPS_P21 = .;
IF UPPS_P22 = -99 THEN UPPS_P22 = .; IF UPPS_P23 = -99 THEN UPPS_P23 = .; IF UPPS_P24 = -99 THEN UPPS_P24 = .;
IF UPPS_P25 = -99 THEN UPPS_P25 = .; IF UPPS_P26 = -99 THEN UPPS_P26 = .; IF UPPS_P27 = -99 THEN UPPS_P27 = .;
IF UPPS_P28 = -99 THEN UPPS_P28 = .; IF UPPS_P29 = -99 THEN UPPS_P29 = .; IF UPPS_P30 = -99 THEN UPPS_P30 = .;
IF UPPS_P31 = -99 THEN UPPS_P31 = .; IF UPPS_P32 = -99 THEN UPPS_P32 = .; IF UPPS_P33 = -99 THEN UPPS_P33 = .;
IF UPPS_P34 = -99 THEN UPPS_P34 = .; IF UPPS_P35 = -99 THEN UPPS_P35 = .; IF UPPS_P36 = -99 THEN UPPS_P36 = .;
IF UPPS_P37 = -99 THEN UPPS_P37 = .; IF UPPS_P38 = -99 THEN UPPS_P38 = .; IF UPPS_P39 = -99 THEN UPPS_P39 = .;
IF UPPS_P40 = -99 THEN UPPS_P40 = .; IF UPPS_P41 = -99 THEN UPPS_P41 = .; IF UPPS_P42 = -99 THEN UPPS_P42 = .;
IF UPPS_P43 = -99 THEN UPPS_P43 = .; IF UPPS_P44 = -99 THEN UPPS_P44 = .; IF UPPS_P45 = -99 THEN UPPS_P45 = .;
IF UPPS_P46 = -99 THEN UPPS_P46 = .; IF UPPS_P47 = -99 THEN UPPS_P47 = .; IF UPPS_P48 = -99 THEN UPPS_P48 = .;
IF UPPS_P49 = -99 THEN UPPS_P49 = .; IF UPPS_P50 = -99 THEN UPPS_P50 = .; IF UPPS_P51 = -99 THEN UPPS_P51 = .;
IF UPPS_P52 = -99 THEN UPPS_P52 = .; IF UPPS_P53 = -99 THEN UPPS_P53 = .; IF UPPS_P54 = -99 THEN UPPS_P54 = .;
IF UPPS_P55 = -99 THEN UPPS_P55 = .; IF UPPS_P56 = -99 THEN UPPS_P56 = .; IF UPPS_P57 = -99 THEN UPPS_P57 = .;
IF UPPS_P58 = -99 THEN UPPS_P58 = .; IF UPPS_P59 = -99 THEN UPPS_P59 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE  UPPS_P1-UPPS_P59;
RUN;
*Reverse Scoring;
DATA Quest_clean;
SET Quest_clean;
UPPS_P53 = 5 - UPPS_P53;

UPPS_P1 = 5 - UPPS_P1;
UPPS_P6 = 5 - UPPS_P6;
UPPS_P11 = 5 - UPPS_P11;
UPPS_P16 = 5 - UPPS_P16;
UPPS_P21 = 5 - UPPS_P21;
UPPS_P28 = 5 - UPPS_P28;
UPPS_P33 = 5 - UPPS_P33;
UPPS_P38 = 5 - UPPS_P38;
UPPS_P43 = 5 - UPPS_P43;
UPPS_P48 = 5 - UPPS_P48;
UPPS_P55 = 5 - UPPS_P55;

UPPS_P4 = 5 - UPPS_P4;
UPPS_P14 = 5 - UPPS_P14;
UPPS_P19 = 5 - UPPS_P19;
UPPS_P24 = 5 - UPPS_P24;
UPPS_P27 = 5 - UPPS_P27;
UPPS_P32 = 5 - UPPS_P32;
UPPS_P37 = 5 - UPPS_P37;
UPPS_P42 = 5 - UPPS_P42;
RUN;
PROC Freq DATA = Quest_clean;
TABLE  UPPS_P1-UPPS_P59;
RUN;
PROC CORR DATA = Quest_clean ALPHA NOMISS;
VAR  UPPS_P1-UPPS_P59;
RUN;
DATA Quest_clean;
SET Quest_clean;
UPPS = mean(of UPPS_P1-UPPS_P59);
UPPS_miss = cmiss(of UPPS_P1-UPPS_P59);

UPPS_NegUrg = mean(UPPS_P2, UPPS_P7, UPPS_P12, UPPS_P17, UPPS_P22, UPPS_P29, UPPS_P34, UPPS_P39, UPPS_P44,
				   UPPS_P50, UPPS_P53, UPPS_P58);
UPPS_NegUrg_miss = cmiss(UPPS_P2, UPPS_P7, UPPS_P12, UPPS_P17, UPPS_P22, UPPS_P29, UPPS_P34, UPPS_P39, UPPS_P44,
				   UPPS_P50, UPPS_P53, UPPS_P58);

UPPS_Prem = mean(UPPS_P1, UPPS_P6, UPPS_P11, UPPS_P16, UPPS_P21, UPPS_P28, UPPS_P33, UPPS_P38, UPPS_P43,
				   UPPS_P48, UPPS_P55);
UPPS_Prem_miss = cmiss(UPPS_P1, UPPS_P6, UPPS_P11, UPPS_P16, UPPS_P21, UPPS_P28, UPPS_P33, UPPS_P38, UPPS_P43,
				   UPPS_P48, UPPS_P55);

UPPS_Pers = mean(UPPS_P4, UPPS_P9, UPPS_P14, UPPS_P19, UPPS_P24, UPPS_P27, UPPS_P32, UPPS_P37, UPPS_P42,
				   UPPS_P47);
UPPS_Pers_miss = cmiss(UPPS_P4, UPPS_P9, UPPS_P14, UPPS_P19, UPPS_P24, UPPS_P27, UPPS_P32, UPPS_P37, UPPS_P42,
				   UPPS_P47);

UPPS_Sens = mean(UPPS_P3, UPPS_P8, UPPS_P13, UPPS_P18, UPPS_P23, UPPS_P26, UPPS_P31, UPPS_P36, UPPS_P41,
				   UPPS_P46, UPPS_P51, UPPS_P56);
UPPS_Sens_miss = cmiss(UPPS_P3, UPPS_P8, UPPS_P13, UPPS_P18, UPPS_P23, UPPS_P26, UPPS_P31, UPPS_P36, UPPS_P41,
				   UPPS_P46, UPPS_P51, UPPS_P56);

UPPS_PosUrg = mean(UPPS_P5, UPPS_P10, UPPS_P15, UPPS_P20, UPPS_P25, UPPS_P30, UPPS_P35, UPPS_P40, UPPS_P45,
				   UPPS_P49, UPPS_P52, UPPS_P54, UPPS_P57, UPPS_P59);
UPPS_PosUrg_miss = cmiss(UPPS_P5, UPPS_P10, UPPS_P15, UPPS_P20, UPPS_P25, UPPS_P30, UPPS_P35, UPPS_P40, UPPS_P45,
				   UPPS_P49, UPPS_P52, UPPS_P54, UPPS_P57, UPPS_P59);
RUN;
PROC Freq DATA = Quest_clean;
TABLE UPPS_miss  UPPS_NegUrg_miss  UPPS_Prem_miss  UPPS_Pers_miss  UPPS_Sens_miss  UPPS_PosUrg_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF UPPS_P_miss >= 18 THEN UPPS_P = .;
IF UPPS_P_miss >= 18 THEN UPPS_NegUrg = .;
IF UPPS_P_miss >= 18 THEN UPPS_Prem = .;
IF UPPS_P_miss >= 18 THEN UPPS_Pers = .;
IF UPPS_P_miss >= 18 THEN UPPS_Sens = .;
IF UPPS_P_miss >= 18 THEN UPPS_PosUrg = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR UPPS UPPS_NegUrg  UPPS_Prem  UPPS_Pers  UPPS_Sens  UPPS_PosUrg;
HISTOGRAM UPPS UPPS_NegUrg  UPPS_Prem  UPPS_Pers  UPPS_Sens  UPPS_PosUrg;
RUN;

*DelGrat;
DATA Quest_clean;
SET Quest_clean;
IF DelGrat1 = -99 THEN DelGrat1 = .;   IF DelGrat2 = -99 THEN DelGrat2 = .;   IF DelGrat3 = -99 THEN DelGrat3 = .;  
IF DelGrat4 = -99 THEN DelGrat4 = .;   IF DelGrat5 = -99 THEN DelGrat5 = .;   IF DelGrat6 = -99 THEN DelGrat6 = .;  
IF DelGrat7 = -99 THEN DelGrat7 = .;   IF DelGrat8 = -99 THEN DelGrat8 = .;   IF DelGrat9 = -99 THEN DelGrat9 = .;  
IF DelGrat10 = -99 THEN DelGrat10 = .; IF DelGrat11 = -99 THEN DelGrat11 = .; IF DelGrat12 = -99 THEN DelGrat12 = .;
RUN;
DATA Quest_clean;
SET Quest_clean;
DelGrat4 = 6 - DelGrat4;
DelGrat5 = 6 - DelGrat5;
DelGrat6 = 6 - DelGrat6;
DelGrat7 = 6 - DelGrat7;
DelGrat9 = 6 - DelGrat9;
DelGrat10 = 6 - DelGrat10;
RUN;
PROC Freq DATA = Quest_clean;
TABLE DelGrat1-DelGrat12;
RUN;
PROC CORR DATA = Quest_clean ALPHA NOMISS;
VAR DelGrat1-DelGrat12;
RUN;
DATA Quest_clean;
SET Quest_clean;
DelGrat = mean(of DelGrat1-DelGrat12);
DelGrat_miss = cmiss(of DelGrat1-DelGrat12);
RUN;
PROC Freq DATA = Quest_clean;
TABLE DelGrat_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF DelGrat_miss >= 4 THEN DelGrat = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR DelGrat;
HISTOGRAM DelGrat;
RUN;

*Brief Self-Control Scale;
DATA Quest_clean;
SET Quest_clean;
IF BriefSC1 = -99 THEN BriefSC1 = .;   IF BriefSC2 = -99 THEN BriefSC2 = .;   IF BriefSC3 = -99 THEN BriefSC3 = .;  
IF BriefSC4 = -99 THEN BriefSC4 = .;   IF BriefSC5 = -99 THEN BriefSC5 = .;   IF BriefSC6 = -99 THEN BriefSC6 = .;  
IF BriefSC7 = -99 THEN BriefSC7 = .;   IF BriefSC8 = -99 THEN BriefSC8 = .;   IF BriefSC9 = -99 THEN BriefSC9 = .;  
IF BriefSC10 = -99 THEN BriefSC10 = .; IF BriefSC11 = -99 THEN BriefSC11 = .; IF BriefSC12 = -99 THEN BriefSC12 = .;
IF BriefSC12 = -99 THEN BriefSC13 = .;
RUN;
DATA Quest_clean;
SET Quest_clean;
BriefSC2 = 6 - BriefSC2;
BriefSC3 = 6 - BriefSC3;
BriefSC4 = 6 - BriefSC4;
BriefSC5 = 6 - BriefSC5;
BriefSC6 = 6 - BriefSC6;
BriefSC7 = 6 - BriefSC7;
BriefSC8 = 6 - BriefSC8;
BriefSC10 = 6 - BriefSC10;
BriefSC11 = 6 - BriefSC11;
RUN;
PROC Freq DATA = Quest_clean;
TABLE BriefSC1-BriefSC13;
RUN;
PROC CORR DATA = Quest_clean ALPHA NOMISS;
VAR BriefSC1-BriefSC13;
RUN;
DATA Quest_clean;
SET Quest_clean;
BriefSC = mean(of BriefSC1-BriefSC13);
BriefSC_miss = cmiss(of BriefSC1-BriefSC13);

BriefSC_Res = mean(BriefSC5, BriefSC7, BriefSC10, BriefSC11);
BriefSC_Res_miss = cmiss(BriefSC5, BriefSC7, BriefSC10, BriefSC11);

BriefSC_Imp = mean(BriefSC1, BriefSC2, BriefSC6, BriefSC13);
BriefSC_Imp_miss = cmiss(BriefSC1, BriefSC2, BriefSC6, BriefSC13);
RUN;
PROC Freq DATA = Quest_clean;
TABLE BriefSC_miss  BriefSC_Res_miss  BriefSC_Imp_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF BriefSC_miss >= 4 THEN BriefSC = .;
IF BriefSC_Res_miss >= 2 THEN BriefSC_Res = .;
IF BriefSC_Imp_miss >= 2 THEN BriefSC_Imp = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR BriefSC BriefSC_Res BriefSC_Imp;
HISTOGRAM BriefSC BriefSC_Res BriefSC_Imp;
RUN;

DATA Quest_clean;
SET Quest_clean;
IF SocDes1 = -99 THEN SocDes1 = .;   IF SocDes2 = -99 THEN SocDes2 = .;  
IF SocDes3 = -99 THEN SocDes3 = .;   IF SocDes4 = -99 THEN SocDes4 = .;  
IF SocDes5 = -99 THEN SocDes5 = .;   IF SocDes6 = -99 THEN SocDes6 = .;  
IF SocDes7 = -99 THEN SocDes7 = .;   IF SocDes8 = -99 THEN SocDes8 = .;  
IF SocDes9 = -99 THEN SocDes9 = .;   IF SocDes10 = -99 THEN SocDes10 = .;
IF SocDes11 = -99 THEN SocDes11 = .; IF SocDes12 = -99 THEN SocDes12 = .;
IF SocDes13 = -99 THEN SocDes13 = .; IF SocDes14 = -99 THEN SocDes14 = .;
IF SocDes15 = -99 THEN SocDes15 = .; IF SocDes16 = -99 THEN SocDes16 = .;
IF SocDes17 = -99 THEN SocDes17 = .; IF SocDes18 = -99 THEN SocDes18 = .;
IF SocDes19 = -99 THEN SocDes19 = .; IF SocDes20 = -99 THEN SocDes20 = .;
IF SocDes21 = -99 THEN SocDes21 = .; IF SocDes22 = -99 THEN SocDes22 = .;
IF SocDes23 = -99 THEN SocDes23 = .; IF SocDes24 = -99 THEN SocDes24 = .;
IF SocDes25 = -99 THEN SocDes25 = .; IF SocDes26 = -99 THEN SocDes26 = .;
IF SocDes27 = -99 THEN SocDes27 = .; IF SocDes28 = -99 THEN SocDes28 = .;
IF SocDes29 = -99 THEN SocDes29 = .; IF SocDes30 = -99 THEN SocDes30 = .;
IF SocDes31 = -99 THEN SocDes31 = .; IF SocDes32 = -99 THEN SocDes32 = .;
IF SocDes33 = -99 THEN SocDes33 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE SocDes1-SocDes33;
RUN;
DATA Quest_clean;
SET Quest_clean;
SocDes1 = 3 - SocDes1;
SocDes2 = 3 - SocDes2;
SocDes4 = 3 - SocDes4;
SocDes7 = 3 - SocDes7;
SocDes8 = 3 - SocDes8;
SocDes13 = 3 - SocDes13;
SocDes16 = 3 - SocDes16;
SocDes17 = 3 - SocDes17;
SocDes18 = 3 - SocDes18;
SocDes20 = 3 - SocDes20;
SocDes21 = 3 - SocDes21;
SocDes24 = 3 - SocDes24;
SocDes25 = 3 - SocDes25;
SocDes26 = 3 - SocDes26;
SocDes27 = 3 - SocDes27;
SocDes29 = 3 - SocDes29;
SocDes31 = 3 - SocDes31;
SocDes33 = 3 - SocDes33;
RUN;
DATA Quest_clean;
SET Quest_clean;
SocDes = mean(of SocDes1-SocDes33);
SocDes_miss = cmiss(of SocDes1-SocDes33);
RUN;
PROC Freq DATA = Quest_clean;
TABLE SocDes_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF SocDes_miss >= 10 THEN SocDes = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE SocDes_miss;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR SocDes;
HISTOGRAM SocDes;
RUN;
PROC CORR DATA = Quest_clean ALPHA NOMISS;;
VARIABLE SocDes1-SocDes33;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE UPPS  UPPS_NegUrg  UPPS_Prem  UPPS_Pers  UPPS_Sens  UPPS_PosUrg  DelGrat  
		 BriefSC  BriefSC_Res  BriefSC_Imp  SES  SocDes;
RUN;


********************************************Outcomes*********************************************;
**********School**********;
*Semester;
DATA Quest_clean;
SET Quest_clean;
SchoolYear = Q381;
RUN;
PROC Freq DATA = Quest_clean;
TABLE SchoolSem SchoolYear;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF SchoolSem = -99 THEN SchoolSem = .; 
IF SchoolYear = -99 THEN SchoolYear = .;  
RUN;
PROC Freq DATA = Quest_clean;
TABLE SchoolSem SchoolYear;
RUN;
*School Engagement;
PROC Freq DATA = Quest_clean;
TABLE SchoolEng1 - SchoolEng12;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF schoolEng1 = -99 THEN schoolEng1 = .;   IF schoolEng2 = -99 THEN schoolEng2 = .;   IF schoolEng3 = -99 THEN schoolEng3 = .;  
IF schoolEng4 = -99 THEN schoolEng4 = .;   IF schoolEng5 = -99 THEN schoolEng5 = .;   IF schoolEng6 = -99 THEN schoolEng6 = .;  
IF schoolEng7 = -99 THEN schoolEng7 = .;   IF schoolEng8 = -99 THEN schoolEng8 = .;   IF schoolEng9 = -99 THEN schoolEng9 = .;  
IF schoolEng10 = -99 THEN schoolEng10 = .; IF schoolEng11 = -99 THEN schoolEng11 = .; IF schoolEng12 = -99 THEN schoolEng12 = .;
RUN;
DATA Quest_clean;
SET Quest_clean;
SchoolEng7 = 6 - SchoolEng7;
SchoolEng8 = 6 - SchoolEng8;
SchoolEng9 = 6 - SchoolEng9;
SchoolEng10 = 6 - SchoolEng10;
SchoolEng11 = 6 - SchoolEng11;
SchoolEng12 = 6 - SchoolEng12;
RUN;
PROC CORR DATA = Quest_clean ALPHA NOMISS;;
VARIABLE SchoolEng1-SchoolEng12;
RUN;
DATA Quest_clean;
SET Quest_clean;
SchoolEng = mean(of SchoolEng1 - SchoolEng12);
SchoolEng_BEng = mean(of SchoolEng1 - SchoolEng3);
SchoolEng_EEng = mean(of SchoolEng4 - SchoolEng6);
SchoolEng_BDis = mean(of SchoolEng7 - SchoolEng9);
SchoolEng_EDis = mean(of SchoolEng10 - SchoolEng12);
SchoolEng_miss = cmiss(of SchoolEng1-SchoolEng12);
RUN;
PROC Freq DATA = Quest_clean;
TABLE SchoolEng_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF SchoolEng_miss > 3 THEN SchoolEng = .;
IF SchoolEng_miss > 3 THEN SchoolEng_BEng = .;
IF SchoolEng_miss > 3 THEN SchoolEng_EEng = .;
IF SchoolEng_miss > 3 THEN SchoolEng_BDis = .;
IF SchoolEng_miss > 3 THEN SchoolEng_EDis = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR SchoolEng;
HISTOGRAM SchoolEng;
RUN;
*Efficacy;
PROC Freq DATA = Quest_clean;
TABLE SchoolEff1 - SchoolEff4;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF SchoolEff1 = -99 THEN SchoolEff1 = .; IF SchoolEff2 = -99 THEN SchoolEff2 = .; IF SchoolEff3 = -99 THEN SchoolEff3 = .;
IF SchoolEff4 = -99 THEN SchoolEff4 = 
RUN;
PROC Freq DATA = Quest_clean;
TABLE SchoolEff1 - SchoolEff4;
RUN;
PROC CORR DATA = Quest_clean ALPHA NOMISS;;
VARIABLE SchoolEff1 - SchoolEff4;
RUN;
DATA Quest_clean;
SET Quest_clean;
SchoolEff = mean(of SchoolEff1 - SchoolEff4);
SchoolEff_miss = cmiss(of SchoolEff1 - SchoolEff4);
RUN;
PROC Freq DATA = Quest_clean;
TABLE SchoolEff_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF SchoolEff_miss > 1 THEN SchoolEff = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR SchoolEff;
HISTOGRAM SchoolEff;
RUN;
DATA Quest_clean;
SET Quest_clean;
SchoolEff_log = log(SchoolEff);
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR SchoolEff_log;
HISTOGRAM SchoolEff_log;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE ACTTot SATNewTot SchoolGPA SchoolStrat SchoolEng  SchoolEff;
RUN;
PROC REG DATA = Quest_clean;
MODEL SchoolGPA = SocDes BriefSC;
RUN;
PROC CORR DATA = Quest_clean;
VARIABLE SchoolEng  SchoolEng_BEng  SchoolEng_EEng  SchoolEng_BDis  SchoolEng_EDis  SchoolEff  SocDes UPPS  BriefSC  DelGrat;
RUN;
PROC CORR DATA = Quest_clean;
VARIABLE SocDes UPPS  UPPS_NegUrg  UPPS_Prem  UPPS_Pers  UPPS_Sens  UPPS_PosUrg  DelGrat  
		 BriefSC  BriefSC_Res  BriefSC_Imp  SES SchoolEng SchoolEff;
RUN;
*Cognitive Engagement;
DATA Quest_clean;
SET Quest_clean;
IF SchoolCogStrat1 = -99 THEN SchoolCogStrat1 = .; IF SchoolCogStrat2 = -99 THEN SchoolCogStrat2 = .;
IF SchoolCogStrat3 = -99 THEN SchoolCogStrat3 = .; IF SchoolCogStrat4 = -99 THEN SchoolCogStrat4 = .;
IF SchoolCogStrat5 = -99 THEN SchoolCogStrat5 = .; IF SchoolCogStrat6 = -99 THEN SchoolCogStrat6 = .;
IF SchoolCogStrat7 = -99 THEN SchoolCogStrat7 = .; IF SchoolCogStrat8 = -99 THEN SchoolCogStrat8 = .;
IF SchoolCogStrat9 = -99 THEN SchoolCogStrat9 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE SchoolCogStrat1 - SchoolCogStrat9;
RUN;
PROC CORR DATA = Quest_clean ALPHA NOMISS;;
VARIABLE SchoolCogStrat1 - SchoolCogStrat9;
RUN;
 ods graphics on;
PROC FACTOR DATA=Quest_clean 
			METHOD=P 
			PRIORS=SMC 
			NFACTORS = 3
			ROTATE=PROMAX REORDER SCREE CORR RES;
var SchoolCogStrat1 - SchoolCogStrat9;
RUN;
 ods graphics off;
DATA Quest_clean;
SET Quest_clean;
SchoolStrat = mean(of SchoolCogStrat1 - SchoolCogStrat9);
SchoolStrat_Plan = mean(SchoolCogStrat4, SchoolCogStrat6, SchoolCogStrat1);
SchoolStrat_miss = cmiss(of SchoolCogStrat1 - SchoolCogStrat9);
RUN;
PROC Freq DATA = Quest_clean;
TABLE SchoolStrat_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF SchoolStrat_miss > 2 THEN SchoolStrat = .;
IF SchoolStrat_miss > 2 THEN SchoolStrat_Plan = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR SchoolStrat  SchoolStrat_Plan;
HISTOGRAM SchoolStrat  SchoolStrat_Plan;
RUN;

*GPA;
PROC Freq DATA = Quest_clean;
TABLE SchoolGPAHS;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF SchoolGPAHS = "-99" THEN SchoolGPAHS = ".";
IF SchoolGPAHS = "4.21 out" THEN SchoolGPAHS = "4.21"; 
IF SchoolGPAHS = "3.6?/4.0" THEN SchoolGPAHS = "4.0";  
IF SchoolGPAHS = "3.6/4.5" THEN SchoolGPAHS = "4.5";  
IF SchoolGPAHS = "3.7 or 3" THEN SchoolGPAHS = "3.7";  
IF SchoolGPAHS = "4.08 out" THEN SchoolGPAHS = "4.08";   
IF SchoolGPAHS = "4.36/5" THEN SchoolGPAHS = "5";  
IF SchoolGPAHS = "4.98 wei" THEN SchoolGPAHS = "4.98";  
IF SchoolGPAHS = "4.08 out" THEN SchoolGPAHS = "4.08";    
IF SchoolGPAHS = "4.5/5" THEN SchoolGPAHS = "5"; 
IF SchoolGPAHS = "4.36/5" THEN SchoolGPAHS = "5"; 
IF SchoolGPAHS = "NA" THEN SchoolGPAHS = "."; 
IF SchoolGPAHS = "4.0+" THEN SchoolGPAHS = "4"; 

ACTot = ACTTot + 0;
RUN;
DATA Quest_clean;
SET Quest_clean;
SchoolGPA = input(SchoolGPAHS,4.);
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR SchoolGPA;
HISTOGRAM SchoolGPA;
RUN;
PROC MEANS DATA = Quest_clean;
VAR SchoolGPA;
RUN;
*Act;
DATA Quest_clean;
SET Quest_clean;
IF ACTTot = -99 THEN ACTTot = .;
RUN;
PROC FREQ DATA = Quest_clean;
TABLE ACTTot;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR ACTTot;
HISTOGRAM ACTTot;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR SATNewTot;
HISTOGRAM SATNewTot;
RUN;


**********Exercise**********;
*Stages;
PROC Freq DATA = Quest_clean;
TABLE ExerciseStages_1;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF ExerciseStages_1 = -99 THEN ExerciseStages_1 = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR ExerciseStages_1;
HISTOGRAM ExerciseStages_1;
RUN;
*Frequency;
PROC Freq DATA = Quest_clean;
TABLE ExerciseFreq;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF ExerciseFreq = -99 THEN ExerciseFreq = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR ExerciseFreq;
HISTOGRAM ExerciseFreq;
RUN;
*Composite;
PROC STANDARD DATA = Quest_clean MEAN = 0 STD =1
              OUT = Quest_clean;
			  VAR ExerciseStages_1 ExerciseFreq;
RUN;
DATA Quest_clean;
SET Quest_clean;
ExerciseReport = mean(ExerciseStages_1, ExerciseFreq);
RUN;
*BMI;
DATA Quest_clean;
SET Quest_clean;
HeightFeet2 = HeightFeet * 12;
RUN;
DATA Quest_clean;
SET Quest_clean;
HeightTotInches = HeightFeet2 + HeightInches;
RUN;
DATA Quest_clean;
SET Quest_clean;
Height = HeightTotInches + 0;
DROP HeightTotInches;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Height = -1287 THEN Height = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR Height;
HISTOGRAM Height;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Weight = -99 THEN Weight = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR Weight;
HISTOGRAM Weight;
RUN;
DATA Quest_clean;
SET Quest_clean;
BMI = 703 * (Weight / (Height**2));
RUN;
/*DATA Quest_clean;
SET Quest_clean;
WeightKil = Weight * .453592;
HeightMet = Height * .0254;
BMI = WeightKil / (HeightMet**2);
RUN;*/
PROC UNIVARIATE DATA = Quest_clean;
VAR BMI;
HISTOGRAM BMI;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE BMI ExerciseReport ExerciseFreq ExerciseStages_1;
RUN;
*Internal reliability of composite;
PROC CORR DATA = Quest_clean alpha nomiss;
VARIABLE ExerciseReport ExerciseFreq ExerciseStages_1;
RUN;
PROC CORR DATA = Quest_clean;
VARIABLE BMI ExerciseReport ExerciseFreq ExerciseStages_1 UPPS_NegUrg  UPPS_Prem  UPPS_Pers  UPPS_Sens  UPPS_PosUrg SocDes  BriefSC  DelGrat;
RUN;
*********Diet**********;
*PFat;
DATA Quest_clean;
SET Quest_clean;
IF PFat_1 = -99 THEN PFat_1 = .;   IF PFat_2 = -99 THEN PFat_2 = .;   IF PFat_3 = -99 THEN PFat_3 = .;  
IF PFat_4 = -99 THEN PFat_4 = .;   IF PFat_5 = -99 THEN PFat_5 = .;   IF PFat_6 = -99 THEN PFat_6 = .;  
IF PFat_7 = -99 THEN PFat_7 = .;   IF PFat_8 = -99 THEN PFat_8 = .;   IF PFat_9 = -99 THEN PFat_9 = .;  
IF PFat_10 = -99 THEN PFat_10 = .; IF PFat_11 = -99 THEN PFat_11 = .; IF PFat_12 = -99 THEN PFat_12 = .;
IF PFat_13 = -99 THEN PFat_13 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE PFat_1 - PFat_13;
RUN;
DATA Quest_clean;
SET Quest_clean;
PFat_3 = 9 - PFat_3;
PFat_4 = 9 - PFat_4;
PFat_5 = 9 - PFat_5;
PFat_8 = 9 - PFat_8;
PFat_9 = 9 - PFat_9;
PFat_10 = 9 - PFat_10;
PFat_11 = 9 - PFat_11;
PFat_13 = 9 - PFat_13;
RUN;
PROC CORR DATA = Quest_clean alpha nomiss;
VAR PFat_1 - PFat_13;
RUN;
DATA Quest_clean;
SET Quest_clean;
Fat = mean(of PFat_1 - PFat_13);
Fat_miss = cmiss(of PFat_1 - PFat_13);
RUN;
PROC Freq DATA = Quest_clean;
TABLE Fat_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Fat_miss > 3 THEN Fat = .;
RUN;
*Other individual items;
DATA Quest_clean;
SET Quest_clean;
DietSingle = Q574;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF DietSingle = -99 THEN DietSingle = .; 
IF PFaTOverall = -99 THEN PFaTOverall = .; 
IF PFaTButter = -99 THEN PFaTButter = .; 
RUN; 
PROC UNIVARIATE DATA = Quest_clean;
VAR Fat DietSingle PFaTOverall PFaTButter;
HISTOGRAM Fat DietSingle PFaTOverall PFaTButter;
RUN;
*EAT;
DATA Quest_clean;
SET Quest_clean;
IF EAT1 = -99 THEN EAT1 = .; IF EAT2 = -99 THEN EAT2 = .; IF EAT3 = -99 THEN EAT3 = .; IF EAT4 = -99 THEN EAT4 = .;
IF EAT5 = -99 THEN EAT5 = .; IF EAT6 = -99 THEN EAT6 = .; IF EAT7 = -99 THEN EAT7 = .; IF EAT8 = -99 THEN EAT8 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE EAT1 - EAT8;
RUN;
DATA Quest_clean;
SET Quest_clean;
PFat_3 = 9 - PFat_3;
PFat_4 = 9 - PFat_4;
PFat_5 = 9 - PFat_5;
PFat_8 = 9 - PFat_8;
PFat_9 = 9 - PFat_9;
PFat_10 = 9 - PFat_10;
PFat_11 = 9 - PFat_11;
PFat_13 = 9 - PFat_13;
RUN;
DATA Quest_clean;
SET Quest_clean;
DietDys = mean(of EAT1 - EAT8);
DietDys_miss = cmiss(of EAT1 - EAT8);
RUN;
PROC Freq DATA = Quest_clean;
TABLE DietDys_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF DietDys_miss > 2 THEN DietDys = .;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VARIABLE EAT1 - EAT8;
RUN;
PROC FACTOR DATA = Quest_clean 
			METHOD = P 
			PRIORS = SMC 
			NFACTORS = 2
			ROTATE = PROMAX REORDER SCREE CORR RES;
var EAT1 - EAT8;
RUN;
DATA Quest_clean;
SET Quest_clean;
DietDys_Preoc = mean(EAT1, EAT3, EAT2, EAT6);
DietDys_Other = mean(EAT8, EAT7, EAT5, EAT4);
RUN;
DATA Quest_clean;
SET Quest_clean;
IF DietDys_miss > 2 THEN DietDys_Preoc = .;
IF DietDys_miss > 2 THEN DietDys_Other = .;
RUN;
*Associtions;
PROC CORR DATA = Quest_clean;
VARIABLE DietDys  DietDys_Preoc  DietDys_Other  Fat  PFaTButter  PFaTOverall  DietSingle;
RUN;
*With Exercise and BMI;
PROC CORR DATA = Quest_clean;
VARIABLE DietDys  DietDys_Preoc  DietDys_Other  Fat  PFaTButter  PFaTOverall  DietSingle  BMI  ExerciseReport  ExerciseFreq  ExerciseStages_1;;
RUN;



**********Money**********;
DATA Quest_clean;
SET Quest_clean;

IF MoneyBuy1 = -99 THEN MoneyBuy1 = .; IF MoneyBuy2 = -99 THEN MoneyBuy2 = .; IF MoneyBuy3 = -99 THEN MoneyBuy3 = .;
IF MoneyBuy4 = -99 THEN MoneyBuy4 = .; IF MoneyBuy5 = -99 THEN MoneyBuy5 = .; IF MoneyBuy6 = -99 THEN MoneyBuy6 = .;

IF MoneyFinWB1 = -99 THEN MoneyFinWB1 = .; IF MoneyFinWB2 = -99 THEN MoneyFinWB2 = .; IF MoneyFinWB3 = -99 THEN MoneyFinWB3 = .;
IF MoneyFinWB4 = -99 THEN MoneyFinWB4 = .; IF MoneyFinWB5 = -99 THEN MoneyFinWB5 = .; IF MoneyFinWB6 = -99 THEN MoneyFinWB6 = .;
IF MoneyFinWB7 = -99 THEN MoneyFinWB7 = .; IF MoneyFinWB8 = -99 THEN MoneyFinWB8 = .;

IF MoneyFinWBGen = -99 THEN MoneyFinWBGen = .;

IF MoneyAtt1 = -99 THEN MoneyAtt1 = .; IF MoneyAtt2 = -99 THEN MoneyAtt2 = .; IF MoneyAtt3 = -99 THEN MoneyAtt3 = .;
IF MoneyAtt4 = -99 THEN MoneyAtt4 = .; IF MoneyAtt5 = -99 THEN MoneyAtt5 = .; IF MoneyAtt6 = -99 THEN MoneyAtt6 = .;

IF MoneyParentHelp = -99 THEN MoneyParentHelp = .;

IF MoneyCollege = -99 THEN MoneyCollege = .;

IF MoneyCardTuit = -99 THEN MoneyCardTuit = .;

IF MoneyCardDebt = -99 THEN MoneyCardDebt = .;

IF MoneyCard1 = -99 THEN MoneyCard1 = .;

IF MoneyCard2 = -99 THEN MoneyCard2 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE MoneyBuy1-MoneyBuy6  MoneyFinWB1-MoneyFinWB8  MoneyAtt1-MoneyAtt6  MoneyFinWBGen  MoneyParentHelp  MoneyCollege  MoneyCardTuit
	  MoneyCardDebt  MoneyCard1  MoneyCard2;
RUN;
DATA Quest_clean;
SET Quest_clean;
MoneyBuy1 = 8 - MoneyBuy1;
MoneyBuy2 = 8 - MoneyBuy2;
MoneyBuy3 = 8 - MoneyBuy3;
MoneyBuy4 = 8 - MoneyBuy4;
MoneyBuy5 = 8 - MoneyBuy5;
MoneyBuy6 = 8 - MoneyBuy6;

MoneyFinWB1 = 6 - MoneyFinWB1;
MoneyFinWB2 = 6 - MoneyFinWB2;
MoneyFinWB3 = 6 - MoneyFinWB3;
MoneyFinWB5 = 6 - MoneyFinWB5;
MoneyFinWB6 = 6 - MoneyFinWB6;

MoneyCard1 = 6 - MoneyCard1;
RUN;
DATA Quest_clean;
SET Quest_clean;
Buy = mean(of MoneyBuy1 - MoneyBuy6);
BuyPreoc = mean(of MoneyBuy1 - MoneyBuy3);
BuyImp = mean(of MoneyBuy4 - MoneyBuy6);

FinWB = mean(of MoneyFinWB1 - MoneyFinWB8);
*FinWB2 = mean(of MoneyFinWB1 - MoneyFinWB5);
*FinWB3 = mean(of MoneyFinWB1 - MoneyFinWB6);
*FinWB4 = mean(of MoneyFinWB7 - MoneyFinWB8);

MoneyCons = mean(of MoneyAtt1 - MoneyAtt6);
CreditCard = mean(MoneyCard1, MoneyCard2);

Buy_miss = cmiss(of MoneyBuy1 - MoneyBuy6);
FinWB_miss = cmiss(of MoneyFinWB1 - MoneyFinWB8);
*MoneyCons_miss = cmiss(of MoneyAtt1 - MoneyAtt6);
CreditCard_miss = cmiss(MoneyCard1, MoneyCard2);
Buy_miss = cmiss(of MoneyBuy1 - MoneyBuy6);
BuyPreoc_miss = cmiss(of MoneyBuy1 - MoneyBuy3);
BuyImp_miss = cmiss(of MoneyBuy4 - MoneyBuy6);
RUN;
PROC Freq DATA = Quest_clean;
TABLE Buy_miss FinWB_miss MoneyCons_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Buy_miss > 2 THEN Buy = .;
IF FinWB_miss > 2 THEN FinWB = .;
IF MoneyCons_miss > 2 THEN MoneyCons = .;
IF BuyPreoc_miss > 1 THEN Buy1 = .;
IF BuyImp_miss > 1 THEN Buy2 = .;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE Buy  FinWB  MoneyFinWBGen  MoneyCons CreditCard MoneyCard1 MoneyCard2  MoneyParentHelp MoneyCardTuit;
RUN;
PROC CORR DATA = Quest_clean;
VARIABLE MoneyCard1 MoneyCard2;
RUN;
PROC FACTOR DATA = Quest_clean 
			METHOD = P 
			PRIORS = SMC 
			NFACTORS = 2
			ROTATE = PROMAX REORDER SCREE CORR RES;
var MoneyBuy1 - MoneyBuy6;
RUN;
PROC FACTOR DATA = Quest_clean 
			METHOD = P 
			PRIORS = SMC 
			NFACTORS = 2
			ROTATE = PROMAX REORDER SCREE CORR RES;
var MoneyFinWB1 - MoneyFinWB8;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VARIABLE MoneyFinWB1 - MoneyFinWB8;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VARIABLE MoneyAtt1 - MoneyAtt6;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VARIABLE MoneyBuy1 - MoneyBuy6;
RUN;
PROC CORR DATA = Quest_clean;
VARIABLE Buy BuyPreoc BuyImp FinWB  FinWB2  FinWB3  FinWB4  MoneyFinWBGen  MoneyCons CreditCard MoneyCard1 MoneyCard2  MoneyParentHelp  MoneyCardTuit ;
RUN;


**********Sleep**********;
DATA Quest_clean;
SET Quest_clean;
IF SleepPro1 = -99 THEN SleepPro1 = .; IF SleepPro2 = -99 THEN SleepPro2 = .; IF SleepPro3 = -99 THEN SleepPro3 = .;
IF SleepPro4 = -99 THEN SleepPro4 = .; IF SleepPro5 = -99 THEN SleepPro5 = .; IF SleepPro6 = -99 THEN SleepPro6 = .;
IF SleepPro7 = -99 THEN SleepPro7 = .; IF SleepPro8 = -99 THEN SleepPro8 = .; IF SleepPro9 = -99 THEN SleepPro9 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE SleepPro1 - SleepPro9
RUN;
DATA Quest_clean;
SET Quest_clean;
SleepPro1 = 6 - SleepPro1;
SleepPro4 = 6 - SleepPro4;
SleepPro5 = 6 - SleepPro5;
SleepPro6 = 6 - SleepPro6;
SleepPro8 = 6 - SleepPro8;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VARIABLE SleepPro1 - SleepPro9;
RUN;
DATA Quest_clean;
SET Quest_clean;
Sleep = mean(of SleepPro1 - SleepPro9);
Sleep_miss = cmiss(of SleepPro1 - SleepPro9);
RUN;
PROC Freq DATA = Quest_clean;
TABLE Sleep_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Sleep_miss > 2 THEN Sleep = .;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE Sleep  UPPS  UPPS_NegUrg  UPPS_Prem  UPPS_Pers  UPPS_Sens  UPPS_PosUrg  DelGrat  
		 BriefSC  BriefSC_Res  BriefSC_Imp  SES  SocDes;
RUN;


**********Sex**********;
DATA Quest_clean;
SET Quest_clean;
IF Sex1 = -99 THEN Sex1 = .;   IF Sex2 = -99 THEN Sex2 = .;   IF Sex3 = -99 THEN Sex3 = .;   IF Sex4 = -99 THEN Sex4 = .;   IF Sex5 = -99 THEN Sex5 = .;  
IF Sex6 = -99 THEN Sex6 = .;   IF Sex7 = -99 THEN Sex7 = .;   IF Sex8 = -99 THEN Sex8 = .;   IF Sex9 = -99 THEN Sex9 = .;   IF Sex10 = -99 THEN Sex10 = .;
IF Sex11 = -99 THEN Sex11 = .; IF Sex12 = -99 THEN Sex12 = .; IF Sex13 = -99 THEN Sex13 = .; IF Sex14 = -99 THEN Sex14 = .; IF Sex15 = -99 THEN Sex15 = .;
IF Sex16 = -99 THEN Sex16 = .; IF Sex17 = -99 THEN Sex17 = .; IF Sex18 = -99 THEN Sex18 = .; IF Sex19 = -99 THEN Sex19 = .; IF Sex20 = -99 THEN Sex20 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Sex1 - Sex20;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Sex9 = "10+" THEN Sex9 = 10;
IF Sex9 = "100's" THEN Sex9 = 100;
IF Sex9 = "100+" THEN Sex9 = 100;
IF Sex9 = "15-20" THEN Sex9 = 18;
IF Sex9 = "20+" THEN Sex9 = 20;
IF Sex9 = "30+" THEN Sex9 = 30;
IF Sex9 = "40+" THEN Sex9 = 40;
IF Sex9 = "50+" THEN Sex9 = 50;
IF Sex9 = "80+" THEN Sex9 = 80;
IF Sex9 = "a lot (1 par" THEN Sex9 = .;
IF Sex9 = "a lot" THEN Sex9 = .;
IF Sex9 = "couple times" THEN Sex9 = .;
IF Sex9 = "many" THEN Sex9 = .;
IF Sex9 = "too many" THEN Sex9 = .;

IF Sex11 = "10+" THEN Sex11 = 10;
IF Sex11 = "15+" THEN Sex11 = 15;
IF Sex11 = "30+" THEN Sex11 = 30;
IF Sex11 = "80+" THEN Sex11 = 80;
IF Sex11 = "&lt;" THEN Sex11 = .;
IF Sex11 = "10-M" THEN Sex11 = 10;
IF Sex11 = "100'" THEN Sex11 = 100;
IF Sex11 = "20 o" THEN Sex11 = 20;
IF Sex11 = "20-3" THEN Sex11 = 20;
IF Sex11 = "NA" THEN Sex11 = .;
IF Sex11 = "a lo" THEN Sex11 = .;
IF Sex11 = "alot" THEN Sex11 = .;
IF Sex11 = "alwa" THEN Sex11 = .;
IF Sex11 = "freq" THEN Sex11 = .;
IF Sex11 = "many" THEN Sex11 = .;
IF Sex11 = "~40" THEN Sex11 = 40;
IF Sex11 = "4ish" THEN Sex11 = 4;
Sex9_num = Sex9 + 0;
Sex11_num = Sex11 + 0;
DROP Sex9 Sex11;
RUN;
DATA Quest_clean;
SET Quest_clean;
Sex9 = Sex9_num;
Sex11 = Sex11_num;
DROP Sex9_num Sex11_num;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Sex9 Sex11;
RUN;
*Moving to R to treat extreme values based on percentiles of each of the 20 variables;
PROC EXPORT DATA = Quest_clean
			OUTFILE = "C:\Users\Curt\Box Sync\Bruce Projects\Dissertation\Data\Questionnaire\Quest_SexForR.txt"
			DBMS = tab
			REPLACE;
			RUN;
PROC IMPORT OUT= WORK.Quest_clean 
            DATAFILE= "C:\Users\Curt\Box Sync\Bruce Projects\Dissertation\Data\Questionnaire\Sex_Cleaned.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
*Was going to use standard deviations to deal with extreme values, but due to the extreme skew,
3 SDs and even 6 is not strong enough;
*I still standardize though before aggregating since each item is on a different scale;
DATA Quest_clean;
SET Quest_clean;
IF Sex1 = "NA" THEN Sex1 = .;   IF Sex2 = "NA" THEN Sex2 = .;   IF Sex3 = "NA" THEN Sex3 = .;  
IF Sex4 = "NA" THEN Sex4 = .;   IF Sex5 = "NA" THEN Sex5 = .;   IF Sex6 = "NA" THEN Sex6 = .;  
IF Sex7 = "NA" THEN Sex7 = .;   IF Sex8 = "NA" THEN Sex8 = .;   IF Sex9 = "NA" THEN Sex9 = .;  
IF Sex10 = "NA" THEN Sex10 = .; IF Sex11 = "NA" THEN Sex11 = .; IF Sex12 = "NA" THEN Sex12 = .;
IF Sex13 = "NA" THEN Sex13 = .; IF Sex14 = "NA" THEN Sex14 = .; IF Sex15 = "NA" THEN Sex15 = .;
IF Sex16 = "NA" THEN Sex16 = .; IF Sex17 = "NA" THEN Sex17 = .; IF Sex18 = "NA" THEN Sex18 = .;
IF Sex19 = "NA" THEN Sex19 = .; IF Sex20 = "NA" THEN Sex20 = .;
Sex9_num = Sex9 + 0;
DROP Sex9;
RUN;
DATA Quest_clean;
SET Quest_clean;
Sex9 = Sex9_num;
DROP Sex9_num;
RUN;
/*
PROC STANDARD DATA = Quest_clean MEAN = 0 STD =1
              OUT = Quest_clean;
			  VAR Sex1 - Sex20;
RUN;

PROC UNIVARIATE DATA = Quest_clean noprint;
HISTOGRAM Sex1 - Sex20;
RUN;
PROC Freq DATA = Quest_clean_test;
TABLE Sex1 - Sex20;
RUN;
*/
DATA Quest_clean;
SET Quest_clean;
SexRisk = mean(of Sex1 - Sex20);
Sex_miss = cmiss(of Sex1 - Sex20);
RUN;
PROC Freq DATA = Quest_clean;
TABLE Sex_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Sex_miss > 5 THEN SexRisk = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean noprint;
HISTOGRAM SexRisk;
RUN;


**********Media**********;
DATA Quest_clean;
SET Quest_clean;
IF TVFreq = -99 THEN TVFreq = .;
IF FreqQuantDay = -99 THEN FreqQuantDay = .;
IF FreqQuantEnd = -99 THEN FreqQuantEnd = .;

IF GameFreq = -99 THEN GameFreq = .;
IF GameQuantDayTot = -99 THEN GameQuantDayTot = .;
IF GameQuantEndTot = -99 THEN GameQuantEndTot = .;
IF GameQuantDayNotphone = -99 THEN GameQuantDayNotphone = .;
IF GameQuantEndNotphone = -99 THEN GameQuantEndNotphone = .;

IF GameGenre = -99 THEN GameGenre = .;

IF GamePath1 = -99 THEN GamePath1 = .; IF GamePath2 = -99 THEN GamePath2 = .; IF GamePath3 = -99 THEN GamePath3 = .;
IF GamePath4 = -99 THEN GamePath4 = .; IF GamePath5 = -99 THEN GamePath5 = .; IF GamePath6 = -99 THEN GamePath6 = .;
IF GamePath7 = -99 THEN GamePath7 = .; IF GamePath8 = -99 THEN GamePath8 = .; IF GamePath9 = -99 THEN GamePath9 = .;
IF GamePath5_5 = -99 THEN GamePath5_5 = .;

IF PhoneYN = -99 THEN PhoneYN = .;
IF PhoneQuant_1 = -99 THEN PhoneQuant_1 = .;
IF PhoneQuant_2 = -99 THEN PhoneQuant_2 = .;
IF PhoneCalls = -99 THEN PhoneCalls = .;
IF PhoneText = -99 THEN PhoneText = .;
IF PhoneSocial= -99 THEN PhoneSocial = .;

IF PhonePUMP1 = -99 THEN PhonePUMP1 = .;   IF PhonePUMP2 = -99 THEN PhonePUMP2 = .;   IF PhonePUMP3 = -99 THEN PhonePUMP3 = .;  
IF PhonePUMP4 = -99 THEN PhonePUMP4 = .;   IF PhonePUMP5 = -99 THEN PhonePUMP5 = .;   IF PhonePUMP6 = -99 THEN PhonePUMP6 = .;  
IF PhonePUMP7 = -99 THEN PhonePUMP7 = .;   IF PhonePUMP8 = -99 THEN PhonePUMP8 = .;   IF PhonePUMP9 = -99 THEN PhonePUMP9 = .;  
IF PhonePUMP10 = -99 THEN PhonePUMP10 = .; IF PhonePUMP11 = -99 THEN PhonePUMP11 = .; IF PhonePUMP12 = -99 THEN PhonePUMP12 = .;
IF PhonePUMP13 = -99 THEN PhonePUMP13 = .; IF PhonePUMP14 = -99 THEN PhonePUMP14 = .; IF PhonePUMP15 = -99 THEN PhonePUMP15 = .;
IF PhonePUMP16 = -99 THEN PhonePUMP16 = .; IF PhonePUMP17 = -99 THEN PhonePUMP17 = .; IF PhonePUMP18 = -99 THEN PhonePUMP18 = .;
IF PhonePUMP19 = -99 THEN PhonePUMP19 = .; IF PhonePUMP20 = -99 THEN PhonePUMP20 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE TVFreq FreqQuantDay FreqQuantEnd GameFreq GameQuantDayTot GameQuantEndTot GameQuantDayNotphone GameQuantEndNotphone GameGenre
PhoneYN PhoneQuant_1 PhoneQuant_2 PhoneCalls PhoneText PhoneSocial;
RUN;
*Video Games;
PROC Freq DATA = Quest_clean;
TABLE GameFreq GameQuantDayTot GameQuantEndTot GameQuantDayNotphone GameQuantEndNotphone GameGenre;
RUN;
*Pathological;
PROC Freq DATA = Quest_clean;
TABLE GamePath1 - Gamepath9 GamePath5_5;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR GamePath1 - Gamepath9;
RUN;
DATA Quest_clean;
SET Quest_clean;

IF GamePath1 = 1 OR GamePath1 = 2 THEN GamePathBin1 = 1;
IF GamePath2 = 1 OR GamePath2 = 2 THEN GamePathBin2 = 1;
IF GamePath3 = 1 OR GamePath3 = 2 THEN GamePathBin3 = 1;
IF GamePath4 = 1 OR GamePath4 = 2 THEN GamePathBin4 = 1;
IF GamePath5 = 1 OR GamePath5 = 2 THEN GamePathBin5 = 1;
IF GamePath6 = 1 OR GamePath6 = 2 THEN GamePathBin6 = 1;
IF GamePath7 = 1 OR GamePath7 = 2 THEN GamePathBin7 = 1;
IF GamePath8 = 1 OR GamePath8 = 2 THEN GamePathBin8 = 1;
IF GamePath9 = 1 OR GamePath9 = 2 THEN GamePathBin9 = 1;

*GamePathScore = sum(of GamePath1 - Gamepath9);
GamePathScore = mean(of GamePath1 - Gamepath9);
*GamePathScore_miss = cmiss(of GamePath1 - Gamepath9);
GamePathScore_miss = cmiss(of GamePath1 - Gamepath9);
*IF GamePathScore_miss > 2 THEN GamePathScore = .;
IF GamePathScore_miss > 2 THEN GamePathCont = .;
*IF GamePathScore > 4 THEN GamePathDiag = 0; *ELSE IF GamePathScore < 5 THEN GamePathDiag = 1;
*IF missing(GameQuantDayNotphone) THEN GamePathDiag = .;

IF GameFreq = 1 THEN GamePathScore = .;
IF GameQuantDayTot = 1 THEN GamePathScore = .;
IF GameQuantDayTot = 2 THEN GamePathScore = .;

IF GameFreq = 1 THEN GameQuantDayTot = .;
RUN;
*Determing Ps with missing values on the items that determine whether the pathology measure is given.
*I wasnt ot make sure people with missing values aren't assigned as non-pathological;
PROC Freq DATA = Quest_clean;
TABLE GameQuantDayNotphone GameQuantEndNotphone  GamePathScore GamePathDiag GamePathCont;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR GameQuantDayNotphone GameQuantEndNotphone GamePathScore GamePathDiag GamePathCont;
HISTOGRAM GameQuantDayNotphone GameQuantEndNotphone GamePathScore GamePathDiag GamePathCont;
RUN;
*Other game measures;
*They are very skewed;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE GameFreq GameQuantDayTot GameQuantEndTot GameQuantDayNotphone GameQuantEndNotphone GamePathScore GamePathDiag GamePathCont; 
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR GameFreq GameQuantDayTot GameQuantEndTot GameQuantDayNotphone GameQuantEndNotphone;
RUN;
PROC MEANS DATA = Quest_clean;
VAR GameFreq GameQuantDayTot GameQuantEndTot GameQuantDayNotphone GameQuantEndNotphone;
RUN;
PROC MEANS DATA = Quest_clean;
CLASS Sex;
VAR GameFreq GameQuantDayTot GameQuantEndTot GameQuantDayNotphone GameQuantEndNotphone;
RUN;

*Television;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VARIABLE TVFreq FreqQuantDay FreqQuantEnd; 
RUN;
PROC Univariate DATA = Quest_clean NoPrint;
HISTOGRAM TVFreq FreqQuantDay FreqQuantEnd;
RUN;
PROC MEANS DATA = Quest_clean;
VAR TVFreq FreqQuantDay FreqQuantEnd;
RUN;
*I don't know. Maybe just keep all of the variables separate besides the existing measures. I'll have to consider transforming some;

*Cell phone;
PROC Freq DATA = Quest_clean;
TABLE PhoneYN PhoneQuant_1 PhoneQuant_2 PhoneCalls PhoneText PhoneSocial;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF PhoneQuant_1 > 24 THEN PhoneQuant_1 = .;
IF PhoneQuant_2 > 59 THEN PhoneQuant_2 = .;
PhoneQuantTemp = PhoneQuant_2 / 60;
PhoneTime = sum(PhoneQuant_1, PhoneQuantTemp);
RUN;
PROC Freq DATA = Quest_clean;
TABLE PhoneTime PhoneQuantTemp;
RUN;
PROC Univariate DATA = Quest_clean;
VAR PhoneTime;
HISTOGRAM PhoneTime;
RUN;

DATA Quest_clean;
SET Quest_clean;
PhonePUMP1 = 13 - PhonePUMP1;   PhonePUMP2 = 13 - PhonePUMP2;   PhonePUMP3 = 13 - PhonePUMP3;  
PhonePUMP4 = 13 - PhonePUMP4;   PhonePUMP5 = 13 - PhonePUMP5;   PhonePUMP6 = 13 - PhonePUMP6;  
PhonePUMP7 = 13 - PhonePUMP7;   PhonePUMP8 = 13 - PhonePUMP8;   PhonePUMP9 = 13 - PhonePUMP9;  
PhonePUMP10 = 13 - PhonePUMP10; PhonePUMP11 = 13 - PhonePUMP11; PhonePUMP12 = 13 - PhonePUMP12;
PhonePUMP13 = 13 - PhonePUMP13; PhonePUMP14 = 13 - PhonePUMP14; PhonePUMP15 = 13 - PhonePUMP15;
PhonePUMP16 = 13 - PhonePUMP16; PhonePUMP17 = 13 - PhonePUMP17; PhonePUMP18 = 13 - PhonePUMP18;
PhonePUMP19 = 13 - PhonePUMP19; PhonePUMP20 = 13 - PhonePUMP20;
RUN;
PROC Freq DATA = Quest_clean;
TABLE PhonePUMP1 - PhonePUMP20;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VARIABLE PhonePUMP1 - PhonePUMP20; 
RUN;
DATA Quest_clean;
SET Quest_clean;
PhonePath = mean(of PhonePUMP1 - PhonePUMP20);
PhonePath_miss = cmiss(of PhonePUMP1 - PhonePUMP20);
IF PhonePath_miss > 6 THEN PhonePath = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR PhonePath;
HISTOGRAM PhonePath;
RUN;
PROC CORR DATA = Quest_clean;
VARIABLE PhonePath PhoneYN PhoneCalls PhoneSocial PhoneTime; 
RUN;
*Use Duration and PUMP. I need to clean the responses for the call, text, and social media items;


*Relationship;
DATA Quest_clean;
SET Quest_clean;
IF RelatEver = -99 THEN RelatEver = .;
IF RelatQuant = -99 THEN RelatQuant = .;
IF RelatDur = -99 THEN RelatDur = .;
IF RelatMar = -99 THEN RelatMar = .;
IF RelatCurr = -99 THEN RelatCurr = .;
IF RelatDurCurr = -99 THEN RelatDurCurr = .;

IF RelatAcc1Exit1 = -99 THEN RelatAcc1Exit1 = .;
IF RelatAcc2Voice1 = -99 THEN RelatAcc2Voice1 = .;
IF RelatAcc3Loy1 = -99 THEN RelatAcc3Loy1 = .;
IF RelatAcc4Neg1 = -99 THEN RelatAcc4Neg1 = .;
IF RelatAcc5Exit2 = -99 THEN RelatAcc5Exit2 = .;
IF RelatAcc6Voice2 = -99 THEN RelatAcc6Voice2 = .;
IF RelatAcc7Loy2 = -99 THEN RelatAcc7Loy2 = .;
IF RelatAcc8Neg2 = -99 THEN RelatAcc8Neg2 = .;
IF RelatAcc9Exit3 = -99 THEN RelatAcc9Exit3 = .;
IF RelatAcc10Loy3 = -99 THEN RelatAcc10Loy3 = .;
IF RelatAcc1Loy4 = -99 THEN RelatAcc1Loy4 = .;
IF RelatAcc12Neg3 = -99 THEN RelatAcc12Neg3 = .;
IF RelatAcc13Exit4 = -99 THEN RelatAcc13Exit4 = .;
IF RelatAccExit4 = -99 THEN RelatAccExit4 = .;
IF RelatAccVoice3 = -99 THEN RelatAccVoice3 = .;
IF RelatAcc16Voice4 = -99 THEN RelatAcc16Voice4 = .;

IF RelatSat1 = -99 THEN RelatSat1 = .; IF RelatSat2 = -99 THEN RelatSat2 = .; IF RelatSat3 = -99 THEN RelatSat3 = .;
IF RelatSat4 = -99 THEN RelatSat4 = .; IF RelatSat5 = -99 THEN RelatSat5 = .;

IF CheatYN = -99 THEN CheatYN = .;
IF CheatPart = -99 THEN CheatPart = .;
IF CheatQuant = -99 THEN CheatQuant = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE RelatEver  RelatQuant  RelatDur  RelatMar  RelatCurr  RelatDurCurr 
RelatAcc1Exit1 RelatAcc2Voice1  RelatAcc3Loy1  RelatAcc4Neg1  RelatAcc5Exit2  RelatAcc6Voice2  RelatAcc7Loy2 
RelatAcc8Neg2  RelatAcc9Exit3  RelatAcc10Loy3  RelatAcc1Loy4  RelatAcc12Neg3  RelatAcc13Exit4 
RelatAccExit4  RelatAccVoice3  RelatAcc16Voice4
RelatSat1 - RelatSat5 CheatYN CheatPart CheatQuant;
RUN;
DATA Quest_clean;
SET Quest_clean;
RelatAcc4Neg1 = 10 - RelatAcc4Neg1;
RelatAcc8Neg2 = 10 - RelatAcc8Neg2;
RelatAcc12Neg3 = 10 - RelatAcc12Neg3;

RelatAcc1Exit1 = 10 - RelatAcc1Exit1;
RelatAcc5Exit2 = 10 - RelatAcc5Exit2;
RelatAcc9Exit3 = 10 - RelatAcc9Exit3;
RelatAccExit4 = 10 - RelatAccExit4;
RelatAcc13Exit4 = 10 - RelatAcc13Exit4;
RUN;
*Acc;
*Note: I labeled some items wrongly in terms of the categories;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR RelatAcc2Voice1 RelatAcc6Voice2 RelatAccVoice3 RelatAcc10Loy3;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR  RelatAcc3Loy1 RelatAcc7Loy2  RelatAcc1Loy4 RelatAcc16Voice4;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR  RelatAcc4Neg1 RelatAcc8Neg2 RelatAcc12Neg3 RelatAccExit4 ;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR RelatAcc1Exit1 RelatAcc5Exit2 RelatAcc9Exit3 RelatAcc13Exit4 ;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR 
RelatAcc2Voice1 RelatAcc6Voice2 RelatAccVoice3 RelatAcc10Loy3
RelatAcc3Loy1 RelatAcc7Loy2  RelatAcc1Loy4 RelatAcc16Voice4
RelatAcc4Neg1 RelatAcc8Neg2 RelatAcc12Neg3 RelatAccExit4 
RelatAcc1Exit1 RelatAcc5Exit2 RelatAcc9Exit3 RelatAcc13Exit4 ;
RUN;
*Removing two items and re-running;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR 
RelatAcc2Voice1 RelatAcc6Voice2 RelatAccVoice3 RelatAcc10Loy3
RelatAcc3Loy1                    RelatAcc1Loy4 RelatAcc16Voice4
RelatAcc4Neg1 RelatAcc8Neg2                     RelatAccExit4 
RelatAcc1Exit1 RelatAcc5Exit2 RelatAcc9Exit3 RelatAcc13Exit4 ;
RUN;
*Removing the Loy items and re-running;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR 
RelatAcc2Voice1 RelatAcc6Voice2 RelatAccVoice3 RelatAcc10Loy3

RelatAcc4Neg1 RelatAcc8Neg2 RelatAcc12Neg3 RelatAccExit4 
RelatAcc1Exit1 RelatAcc5Exit2 RelatAcc9Exit3 RelatAcc13Exit4 ;
RUN;
*Removing the Loyalty and Neglec items and re-running. This was my original plan;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR 
RelatAcc2Voice1 RelatAcc6Voice2 RelatAccVoice3 RelatAcc10Loy3


RelatAcc1Exit1 RelatAcc5Exit2 RelatAcc9Exit3 RelatAcc13Exit4 ;
RUN;
DATA Quest_clean;
SET Quest_clean;
RelatAccVoice = mean(RelatAcc2Voice1, RelatAcc6Voice2, RelatAccVoice3, RelatAcc10Loy3);
RelatAccVoice_miss = cmiss(RelatAcc2Voice1, RelatAcc6Voice2, RelatAccVoice3, RelatAcc10Loy3);

RelatAccLoy = mean(RelatAcc3Loy1, RelatAcc7Loy2,  RelatAcc1Loy4, RelatAcc16Voice4);
RelatAccLoy_miss = cmiss(RelatAcc3Loy1, RelatAcc7Loy2,  RelatAcc1Loy4, RelatAcc16Voice4);

RelatAccNeg = mean(RelatAcc4Neg1, RelatAcc8Neg2, RelatAcc12Neg3, RelatAccExit4);
RelatAccNeg_miss = cmiss(RelatAcc4Neg1, RelatAcc8Neg2, RelatAcc12Neg3, RelatAccExit4);

RelatAccExit = mean(RelatAcc1Exit1, RelatAcc5Exit2, RelatAcc9Exit3, RelatAcc13Exit4);
RelatAccExit_miss = cmiss(RelatAcc1Exit1, RelatAcc5Exit2, RelatAcc9Exit3, RelatAcc13Exit4);

RelatAcc = mean(
RelatAcc2Voice1, RelatAcc6Voice2, RelatAccVoice3, RelatAcc10Loy3,
RelatAcc3Loy1, RelatAcc7Loy2,  RelatAcc1Loy4, RelatAcc16Voice4,
RelatAcc4Neg1, RelatAcc8Neg2, RelatAcc12Neg3, RelatAccExit4,
RelatAcc1Exit1, RelatAcc5Exit2, RelatAcc9Exit3, RelatAcc13Exit4);
RelatAcc_miss = cmiss(
RelatAcc2Voice1, RelatAcc6Voice2, RelatAccVoice3, RelatAcc10Loy3,
RelatAcc3Loy1, RelatAcc7Loy2,  RelatAcc1Loy4, RelatAcc16Voice4,
RelatAcc4Neg1, RelatAcc8Neg2, RelatAcc12Neg3, RelatAccExit4,
RelatAcc1Exit1, RelatAcc5Exit2, RelatAcc9Exit3, RelatAcc13Exit4);

*Without Loyalty;
RelatAccNoLoy = mean(
RelatAcc2Voice1, RelatAcc6Voice2, RelatAccVoice3, RelatAcc10Loy3,

RelatAcc4Neg1, RelatAcc8Neg2, RelatAcc12Neg3, RelatAccExit4,
RelatAcc1Exit1, RelatAcc5Exit2, RelatAcc9Exit3, RelatAcc13Exit4);
RelatAccNoLoy_miss = cmiss(
RelatAcc2Voice1, RelatAcc6Voice2, RelatAccVoice3, RelatAcc10Loy3,

RelatAcc4Neg1, RelatAcc8Neg2, RelatAcc12Neg3, RelatAccExit4,
RelatAcc1Exit1, RelatAcc5Exit2, RelatAcc9Exit3, RelatAcc13Exit4);
RUN;
DATA Quest_clean;
SET Quest_clean;
IF RelatAccVoice_miss > 1 THEN RelatAccVoice = .;
IF RelatAccLoy_miss > 1 THEN RelatAccLoy = .;
IF RelatAccNeg_miss > 1 THEN RelatAccNeg = .;
IF RelatAccExit_miss > 1 THEN RelatAccExit = .;
IF RelatAcc_miss > 4 THEN RelatAcc = .;

IF RelatAccNoLoy_miss > 4 THEN RelatAccNoLoy = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR RelatAccVoice RelatAccLoy RelatAccNeg RelatAccExit RelatAcc RelatAccNoLoy;
HISTOGRAM RelatAccVoice RelatAccLoy RelatAccNeg RelatAccExit RelatAcc RelatAccNoLoy;
RUN;
PROC CORR DATA = Quest_clean;
VAR RelatAccNoLoy RelatAcc RelatAccVoice RelatAccLoy RelatAccNeg RelatAccExit;
RUN;
*****************Note: use the NoLoyalty version of the composite since it has a higher alpha (.80 vs .78). Also loyalty is negatively correlated with neglect
I think I'll use the four facet measures and the NoLoyalty aggregate;

*Relationship Satisfaction;
DATA Quest_clean;
SET Quest_clean;
RelatSat = mean(of RelatSat1 - RelatSat5);
RelatSat_miss = cmiss(of RelatSat1 - RelatSat5);
RUN;
PROC Freq DATA = Quest_clean;
TABLE RelatSat_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF RelatSat_miss > 1 THEN RelatSat = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR RelatSat1 - RelatSat5;
HISTOGRAM RelatSat1 - RelatSat5;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR RelatSat1 - RelatSat5;
RUN;
*I need to look as a function of currently in a relationship or not;
DATA Quest_clean_No;
SET Quest_clean;
IF RelatCurr = 5 THEN DELETE;
RUN;
DATA Quest_clean_Yes;
SET Quest_clean;
IF RelatCurr = 6 THEN DELETE;
RUN;
PROC CORR DATA = Quest_clean_Yes;
VAR RelatAccNoLoy RelatSat_log
	RelatEver  RelatQuant  RelatDur  RelatMar RelatDurCurr CheatYN CheatPart CheatQuant;
RUN;
PROC CORR DATA = Quest_clean_No;
VAR RelatAccNoLoy RelatSat_log
	RelatEver  RelatQuant  RelatDur  RelatMar RelatDurCurr CheatYN CheatPart CheatQuant;
RUN;
PROC UNIVARIATE DATA = Quest_clean_Yes;
VAR RelatSat RelatAccNoLoy;
HISTOGRAM RelatSat RelatAccNoLoy;
RUN;
PROC UNIVARIATE DATA = Quest_clean_No;
VAR RelatSat RelatAccNoLoy;
HISTOGRAM RelatSat RelatAccNoLoy;
RUN;
PROC TTEST DATA = Quest_clean alpha = .05;
CLASS RelatCurr;
VAR RelatSat_log;
RUN;
PROC TTEST DATA = Quest_clean alpha = .05;
CLASS RelatCurr;
VAR RelatAccNoLoy;
RUN;
*Setting Relationship Satisfaction to . for people not currently in a relationship;
DATA Quest_clean;
SET Quest_clean;
IF RelatCurr = 6 THEN RelatCurr = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR RelatSat;
HISTOGRAM RelatSat;
RUN;
DATA Quest_clean;
SET Quest_clean;
RelatSat_rev = 9 + 1 - RelatSat;
RelatSat_log = log(RelatSat_rev);
RelatSat_Log10 = log10(RelatSat_rev);
RelatSat_arc = arsin(RelatSat);
RelatSat_sq = RelatSat**2;
RUN;
PROC UNIVARIATE DATA = Quest_clean noprint;
VAR RelatSat RelatSat_sq RelatSat_rev RelatSat_log RelatSat_arc RelatSat_Log10; 
HISTOGRAM RelatSat RelatSat_sq RelatSat_rev RelatSat_log RelatSat_arc RelatSat_Log10;
RUN;
DATA Quest_clean_new;
*SET Quest_clean;
      Z = 0;
      DO Sub = 1 TO 287;
	  	OUTPUT;
      END;
   RUN;
DATA Quest_clean_new;
SET Quest_clean_new;
Subject_char = put(Sub,3.);
DROP Subject;
RUN;
DATA Quest_clean_new;
SET Quest_clean_new;
Subject = Subject_char;
DROP Subject_char;
RUN;
DATA Quest_clean;
MERGE Quest_clean Quest_clean_new;
RUN;
ods graphics on;
PROC TRANSREG DATA = Quest_clean MAXITER = 0 NOZEROCONSTANT;
   MODEL BOXCOX(RelatSat/ lambda=-2 -1 -0.5 to 0.5 by 0.05 1 2
                       convenient  alpha=0.00001) = IDENTITY(Z); *You can cut out everything after /. "convenient" will use useful integer parameters if they are within the CI;
   OUTPUT;
RUN;
ods graphics off;
*Set lambda equal to 1;
ods graphics on;
PROC TRANSREG DATA = Quest_clean MAXITER = 0 NOZEROCONSTANT;
   MODEL BOXCOX(RelatSat/ lambda= -1 -0.5 to 0.5 by 0.05 1
                       convenient  alpha=0.00001) = IDENTITY(Z); *You can cut out everything after /. "convenient" will use useful integer parameters if they are within the CI;
   OUTPUT;
RUN;
ods graphics off;
proc univariate noprint;
   histogram RelatSat tRelatSat;
run;
*Not sure what to use. Maybe try rank normatlization;
*Maybe check the original variable, the sq one, and the log one;
*Have to reverse the log variable;
PROC UNIVARIATE DATA = Quest_clean;
VAR RelatSat_log;
HISTOGRAM RelatSat_log;
RUN;
DATA Quest_clean;
SET Quest_clean;
RelatSat_log = 2.19722 + 0 - RelatSat_log;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VAR RelatAccNoLoy RelatSat RelatSat_log RelatSat_sq
	RelatEver  RelatQuant  RelatDur  RelatMar  RelatCurr  RelatDurCurr CheatYN CheatPart CheatQuant;
RUN;
*The additional variables (cheating etc) 
PROC CORR DATA = Quest_clean;
VAR RelatAccNoLoy RelatAcc RelatAccVoice RelatAccLoy RelatAccNeg RelatAccExit 
    RelatSat RelatSat_sq RelatSat_log;
RUN;
*Adding other relationship variables;
PROC CORR DATA = Quest_clean;
VAR RelatAccNoLoy RelatAcc RelatAccVoice RelatAccLoy RelatAccNeg RelatAccExit 
    RelatSat RelatSat_sq RelatSat_log
	RelatEver  RelatQuant  RelatDur  RelatMar  RelatCurr  RelatDurCurr CheatYN CheatPart CheatQuant;
RUN;
*Cheating behavior;
PROC Freq DATA = Quest;
TABLE CheatYN;
RUN;


*Work;
DATA Quest_clean;
SET Quest_clean;
IF WorkStat = -99 THEN WorkStat = .;
IF WorkQuant = -99 THEN WorkQuant = .;
IF WorkEver = -99 THEN WorkEver = .;
IF WorkQuantAvg = -99 THEN WorkQuantAvg = .;

IF WorkPres1 = -99 THEN WorkPres1 = .; IF WorkPres2 = -99 THEN WorkPres2 = .; IF WorkPres3 = -99 THEN WorkPres3 = .;
IF WorkPres4 = -99 THEN WorkPres4 = .; IF WorkPres5 = -99 THEN WorkPres5 = .; IF WorkPres6 = -99 THEN WorkPres6 = .;

IF WorkPress7 = -99 THEN WorkPress7 = .;

IF WorkPresPast1 = -99 THEN WorkPresPast1 = .; IF WorkPresPast2 = -99 THEN WorkPresPast2 = .;
IF WorkPresPast3 = -99 THEN WorkPresPast3 = .; IF WorkPresPast4 = -99 THEN WorkPresPast4 = .;
IF WorkPresPast5 = -99 THEN WorkPresPast5 = .; IF WorkPresPast6 = -99 THEN WorkPresPast6 = .;
IF WorkPresPast7 = -99 THEN WorkPresPast7 = .;

IF Work_Absent1 = -99 THEN Work_Absent1 = .; IF Work_Absent2 = -99 THEN Work_Absent2 = .; IF Work_Absent3 = -99 THEN Work_Absent3 = .;
IF Work_Absent4 = -99 THEN Work_Absent4 = .;

IF Work_AbsentPast1 = -99 THEN Work_AbsentPast1 = .; IF Work_AbsentPast2 = -99 THEN Work_AbsentPast2 = .;
IF Work_AbsentPast3 = -99 THEN Work_AbsentPast3 = .; IF Work_AbsentPast4 = -99 THEN Work_AbsentPast4 = .;

RUN;
PROC Freq DATA = Quest_clean;
TABLE
WorkStat WorkQuant  WorkEver  WorkQuantAvg
WorkPres1 - WorkPres6
WorkPresPast1 - WorkPresPast7
Work_Absent1 - Work_Absent4
Work_AbsentPast1 - Work_AbsentPast4;
RUN;
DATA Quest_clean;
SET Quest_clean;
WorkPres1 = 6 - WorkPres1;
WorkPresPast1 = 6 - WorkPresPast1;
Work_Absent1 = 6 - Work_Absent1;
Work_Absent2 = 6 - Work_Absent2;
Work_Absent3 = 6 - Work_Absent3;
Work_Absent4 = 6 - Work_Absent4;
Work_AbsentPast1 = 6 - Work_AbsentPast1;
Work_AbsentPast2 = 6 - Work_AbsentPast2;
Work_AbsentPast3 = 6 - Work_AbsentPast3;
Work_AbsentPast4 = 6 - Work_AbsentPast4;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR WorkPres1 - WorkPres6;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR WorkPresPast1 - WorkPresPast6;
RUN;
DATA Quest_clean;
SET Quest_clean;
WorkPres = mean(of WorkPres1 - WorkPres6);
WorkPres_miss = cmiss(of WorkPres1 - WorkPres6);
WorkPresPast = mean(of WorkPresPast1 - WorkPresPast6);
WorkPresPast_miss = cmiss(of WorkPresPast1 - WorkPresPast6);
RUN;
PROC Freq DATA = Quest_clean;
TABLE WorkPres_miss  WorkPresPast_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF WorkPres_miss > 1 THEN WorkPres = .;
IF WorkPresPast_miss > 1 THEN WorkPresPast = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR WorkPres WorkPresPast;
HISTOGRAM WorkPres WorkPresPast;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Work_Absent1 - Work_Absent4;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Work_AbsentPast1 - Work_AbsentPast4;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE WorkPres  WorkPresPast  WorkStat  WorkQuant  WorkEver  WorkQuantAvg  Work_Absent1 - Work_Absent4  Work_AbsentPast1 - Work_AbsentPast4;
RUN;
*Note: I should have had all people answer for the past. I can't just use that measure now. I think I'll have to combine present and past.
*Here I'll try to combine the present and past measurs. I should also do this above for relatiionships.;
DATA Quest_clean;
SET Quest_clean;
WorkPresTot = sum(WorkPres, WorkPresPast);
WorkPresSingle = sum(WorkPress7, WorkPresPast7);
WorkAbs1 = sum(Work_Absent1, Work_AbsentPast1);
WorkAbs2 = sum(Work_Absent2, Work_AbsentPast2);
WorkAbs3 = sum(Work_Absent3, Work_AbsentPast3);
WorkAbs4 = sum(Work_Absent4, Work_AbsentPast4);
RUN;
PROC CORR DATA = Quest_clean;
VARIABLE WorkPresTot WorkPres  WorkPresPast WorkPresSingle WorkPress7 WorkPresPast7 WorkAbs1 - WorkAbs4  WorkStat  WorkQuant  WorkEver  WorkQuantAvg  ;
RUN;
*Use WorkPresTot WorkPresSingle and each of the separate Tot WorkAbs items. Could maybe use WorkStat as a control in other variables like school;


*Leisure;
DATA Quest_clean;
SET Quest_clean;
IF Leisure1 = -99 THEN Leisure1 = .;   IF Leisure2 = -99 THEN Leisure2 = .;   IF Leisure3 = -99 THEN Leisure3 = .;  
IF Leisure4 = -99 THEN Leisure4 = .;   IF Leisure5 = -99 THEN Leisure5 = .;   IF Leisure6 = -99 THEN Leisure6 = .;  
IF Leisure7 = -99 THEN Leisure7 = .;   IF Leisure8 = -99 THEN Leisure8 = .;   IF Leisure9 = -99 THEN Leisure9 = .;  
IF Leisure10 = -99 THEN Leisure10 = .; IF Leisure11 = -99 THEN Leisure11 = .; IF Leisure12 = -99 THEN Leisure12 = .;
IF Leisure13 = -99 THEN Leisure13 = .; IF Leisure14 = -99 THEN Leisure14 = .; IF Leisure15 = -99 THEN Leisure15 = .;
IF Leisure16 = -99 THEN Leisure16 = .; IF Leisure17 = -99 THEN Leisure17 = .; IF Leisure18 = -99 THEN Leisure18 = .;
IF Leisure19 = -99 THEN Leisure19 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Leisure1 - Leisure19;
RUN;
DATA Quest_clean;
SET Quest_clean;
Leisure1 = 8 - Leisure1;
Leisure4 = 8 - Leisure4;
Leisure6 = 8 - Leisure6;
Leisure7 = 8 - Leisure7;
Leisure8 = 8 - Leisure8;
Leisure10 = 8 - Leisure10;
Leisure12 = 8 - Leisure12;
Leisure15 = 8 - Leisure15;
Leisure16 = 8 - Leisure16;
Leisure17 = 8 - Leisure17;
RUN;
*Remove all of the items below that are removed;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure1 - Leisure19;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure2 Leisure3 Leisure17 Leisure1 Leisure4 Leisure8 Leisure16 Leisure13 Leisure5 Leisure9 Leisure14 Leisure18 Leisure10 Leisure15 Leisure19;
RUN;
*Remove12;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure2 Leisure3 Leisure17 Leisure12;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure2 Leisure3 Leisure17;
RUN;
*Remove 11;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure1 Leisure4 Leisure8 Leisure16 Leisure13 Leisure11;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure1 Leisure4 Leisure8 Leisure16 Leisure13;
RUN;
*Remove 6;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure5 Leisure6 Leisure9 Leisure14 Leisure18;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure5 Leisure9 Leisure14 Leisure18;
RUN;
*Remove 7;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure10 Leisure15 Leisure19 Leisure7;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Leisure10 Leisure15 Leisure19;
RUN;
*Note: only Boredom and Distress have alphas above .70. Use removed versions. For the total try both versions;
DATA Quest_clean;
SET Quest_clean;
LeisureTot = mean(of Leisure1 - Leisure19);
LeisureTot2 = mean(Leisure2, Leisure3, Leisure17, Leisure1, Leisure4, Leisure8, Leisure16, Leisure13, Leisure5, Leisure9, Leisure14, Leisure18, Leisure10, Leisure15, Leisure19);
LeisureAwar = mean(Leisure2, Leisure3, Leisure17);
LeisureBor = mean(Leisure1, Leisure4, Leisure8, Leisure16, Leisure13);
LeisureChal = mean(Leisure5, Leisure9, Leisure14, Leisure18);
LeisureDist = mean(Leisure10, Leisure15, Leisure19);

LeisureToT_miss = cmiss(of Leisure1 - Leisure19);
LeisureTot2_miss = cmiss(Leisure2, Leisure3, Leisure17, Leisure1, Leisure4, Leisure8, Leisure16, Leisure13, Leisure5, Leisure9, Leisure14, Leisure18, Leisure10, Leisure15, Leisure19);
LeisureAwar_miss = cmiss(Leisure2, Leisure3, Leisure17);
LeisureBor_miss = cmiss(Leisure1, Leisure4, Leisure8, Leisure16, Leisure13);
LeisureChal_miss = cmiss(Leisure5, Leisure9, Leisure14, Leisure18);
LeisureDist_miss = cmiss(Leisure10, Leisure15, Leisure19);
RUN;
PROC Freq DATA = Quest_clean;
TABLE LeisureTo_miss  LeisureTot2_miss  LeisureAwar_miss  LeisureBor_miss  LeisureChal_miss  LeisureDist_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF LeisureToT_miss  > 4 THEN LeisureToT = .;
IF LeisureTot2_miss  > 3 THEN LeisureTot2 = .;
IF LeisureAwar_miss  > 1 THEN LeisureAwar = .;
IF LeisureBor_miss  > 1 THEN LeisureBor = .;
IF LeisureChal_miss  > 1 THEN LeisureChal = .;
IF LeisureDist_miss  > 1 THEN LeisureDist = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR LeisureToT  LeisureTot2  LeisureAwar  LeisureBor  LeisureChal  LeisureDist;
HISTOGRAM LeisureToT  LeisureTot2  LeisureAwar  LeisureBor  LeisureChal  LeisureDist;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE LeisureToT  LeisureTot2  LeisureAwar  LeisureBor  LeisureChal  LeisureDist; 
RUN;
*Use LeisureTot2 and the four facets, but maybe only expect associations with Bor and Dist;


*Aggresion;
DATA Quest_clean;
SET Quest_clean;
IF Agg1P1 = -99 THEN Agg1P1 = .;   
IF Agg2V1 = -99 THEN Agg2V1 = .;   
IF Agg3H1 = -99 THEN Agg3H1 = .;   
IF Agg4P2 = -99 THEN Agg4P2 = .;   
IF Agg5V2 = -99 THEN Agg5V2 = .;   
IF Agg6A1 = -99 THEN Agg6A1 = .;   
IF Agg7H2 = -99 THEN Agg7H2 = .;   
IF Agg8P3 = -99 THEN Agg8P3 = .;   
IF Agg9V3 = -99 THEN Agg9V3 = .;   
IF Agg10P4 = -99 THEN Agg10P4 = .;   
IF Agg11H3 = -99 THEN Agg11H3 = .;   
IF Agg12A2 = -99 THEN Agg12A2 = .;    
RUN;
PROC Freq DATA = Quest_clean;
TABLE  Agg1P1  Agg2V1  Agg3H1  Agg4P2  Agg5V2 Agg7H2  Agg8P3  Agg9V3  Agg10P4 Agg11H3 Agg12A2;
RUN;
DATA Quest_clean;
SET Quest_clean;
Agg1P1 = 6 - Agg1P1 ;
Agg2V1 = 6 - Agg2V1 ;
Agg3H1 = 6 - Agg3H1 ;
Agg4P2 = 6 - Agg4P2 ;
Agg5V2 = 6 - Agg5V2 ;
Agg6A1 = 6 - Agg6A1 ;
Agg7H2 = 6 - Agg7H2 ;
Agg8P3 = 6 - Agg8P3 ;
Agg9V3 = 6 - Agg9V3 ;
Agg10P4 = 6 - Agg10P4;
Agg11H3 = 6 - Agg11H3;
Agg12A2 = 6 - Agg12A2;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Agg1P1  Agg2V1  Agg3H1  Agg4P2  Agg5V2  Agg6A1 Agg7H2 Agg8P3 Agg9V3  Agg10P4 Agg11H3 Agg12A2;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Agg1P1 Agg4P2 Agg8P3 Agg10P4;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Agg2V1 Agg5V2  Agg9V3 ;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Agg3H1 Agg7H2 Agg11H3 ;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Agg6A1 Agg12A2;
RUN;
DATA Quest_clean;
SET Quest_clean;
AggTot = mean(Agg1P1,  Agg2V1,  Agg3H1,  Agg4P2,  Agg5V2,  Agg6A1, Agg7H2, Agg8P3, Agg9V3,  Agg10P4, Agg11H3, Agg12A2);
AggPhy = mean(Agg1P1, Agg4P2, Agg8P3, Agg10P4);
AggVerb = mean(Agg2V1, Agg5V2,  Agg9V3 );
AggHost = mean(Agg3H1, Agg7H2, Agg11H3 );
AggAng = mean(Agg6A1, Agg12A2);

AggTot_miss = cmiss(Agg1P1,  Agg2V1,  Agg3H1,  Agg4P2,  Agg5V2,  Agg6A1, Agg7H2, Agg8P3, Agg9V3,  Agg10P4, Agg11H3, Agg12A2);
AggPhy_miss = cmiss(Agg1P1, Agg4P2, Agg8P3, Agg10P4);
AggVerb_miss = cmiss(Agg2V1, Agg5V2,  Agg9V3 );
AggHost_miss = cmiss(Agg3H1, Agg7H2, Agg11H3 );
AggAng_miss = cmiss(Agg6A1, Agg12A2);
RUN;
PROC Freq DATA = Quest_clean;
TABLE AggTot_miss AggPhy_miss AggVerb_miss AggHost_miss AggAng_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF AggTot_miss  > 3 THEN AggTot = .;
IF AggPhy_miss  > 3 THEN AggPhy = .;
IF AggVerb_miss  > 1 THEN AggVerb = .;
IF AggHost_miss  > 1 THEN AggHost = .;
IF AggAng_miss  > 1 THEN AggAng = .;
RUN;
*Note: not all are normal;
PROC UNIVARIATE DATA = Quest_clean;
VAR AggTot AggPhy AggVerb AggHost AggAng;
HISTOGRAM AggTot AggPhy AggVerb AggHost AggAng;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE AggTot AggPhy AggVerb AggHost AggAng;; 
RUN;



*Smoking;
DATA Quest_clean;
SET Quest_clean;
IF CigCat = -99 THEN CigCat = .; IF CigExDur = -99 THEN CigExDur = .; IF CigQuitSucc = -99 THEN CigQuitSucc = .; IF CigFreqEX = -99 THEN CigFreqEX = .;
IF CigQuantEx = -99 THEN CigQuantEx = .; IF CigFreq = -99 THEN CigFreq = .; IF CigQuant = -99 THEN CigQuant = .;
IF CigCurrDur = -99 THEN CigCurrDur = .; IF CigCurrQuitAtt = -99 THEN CigCurrQuitAtt = .; IF CitCurrQuitQuant = -99 THEN CitCurrQuitQuant = .;

IF Fager1 = -99 THEN Fager1 = .; IF Fager2 = -99 THEN Fager2 = .; IF Fager3 = -99 THEN Fager3 = .; IF Fager4 = -99 THEN Fager4 = .;
IF Fager5 = -99 THEN Fager5 = .; IF Fager6 = -99 THEN Fager6 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE  
CigCat
CigExDur
CigQuitSucc
CigFreqEX
CigQuantEx 
CigFreq
CigQuant
CigCurrDur
CigCurrQuitAtt
CitCurrQuitQuant
Fager1 - Fager6;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF MISSING(Fager2) THEN Smoking = 1;
IF Fager2 = 1 THEN Smoking = 0;
IF Fager2 = 2 THEN Smoking = 0;
IF CigCat = 4 THEN Smoking = 0;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Smoking;
RUN;
*Made a variable of people who were administered the Fagerstrom and past smokers. Will use logistic regression;


*Depression;
DATA Quest_clean;
SET Quest_clean;
IF Dep1 = -99 THEN Dep1 = .; IF Dep2 = -99 THEN Dep2 = .; IF Dep3 = -99 THEN Dep3 = .; IF Dep4 = -99 THEN Dep4 = .;
IF Dep5 = -99 THEN Dep5 = .; IF Dep6 = -99 THEN Dep6 = .; IF Dep7 = -99 THEN Dep7 = .; IF Dep8 = -99 THEN Dep8 = .;   
RUN;
PROC Freq DATA = Quest_clean;
TABLE  Dep1 - Dep8;
RUN;
DATA Quest_clean;
SET Quest_clean;
Dep1 = 5 - Dep1;
Dep2 = 5 - Dep2;
Dep3 = 5 - Dep3;
Dep4 = 5 - Dep4;
Dep5 = 5 - Dep5;
Dep6 = 5 - Dep6;
Dep7 = 5 - Dep7;
Dep8 = 5 - Dep8;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Dep1 - Dep8;
RUN;
DATA Quest_clean;
SET Quest_clean;
DepTot = mean(of Dep1 - Dep8);
Dep_miss = cmiss(of Dep1 - Dep8);;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Dep_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Dep_miss  > 2 THEN Dep_miss = .;
RUN;
*Note: not all are normal;
PROC UNIVARIATE DATA = Quest_clean;
VAR DepTot;
HISTOGRAM DepTot;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE DepTot Dep1 - Dep8; 
RUN;
DATA Quest_clean;
SET Quest_clean;
DepTot_rev = 4 + 1 - DepTot;
DepTot_log = log(DepTot_rev);
DepTot_Log10 = log10(DepTot_rev);
DepTot_sq = DepTot**2;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR DepTot DepTot_log DepTot_Log10 DepTot_sq;
HISTOGRAM DepTot DepTot_log DepTot_Log10 DepTot_sq;
RUN;
*Probably just go with the original even though it is skewed;


*Anxiety;
DATA Quest_clean;
SET Quest_clean;
IF Anx1 = -99 THEN Anx1 = .; IF Anx2 = -99 THEN Anx2 = .; IF Anx3 = -99 THEN Anx3 = .; IF Anx4 = -99 THEN Anx4 = .;
IF Anx5 = -99 THEN Anx5 = .; IF Anx6 = -99 THEN Anx6 = .; IF Anx7 = -99 THEN Anx7 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE  Anx1 - Anx7;
RUN;
DATA Quest_clean;
SET Quest_clean;
Anx1 = 5 - Anx1;
Anx2 = 5 - Anx2;
Anx3 = 5 - Anx3;
Anx4 = 5 - Anx4;
Anx5 = 5 - Anx5;
Anx6 = 5 - Anx6;
Anx7 = 5 - Anx7;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Anx1 - Anx7;
RUN;
DATA Quest_clean;
SET Quest_clean;
AnxTot = mean(of Anx1 - Anx7);
Anx_miss = cmiss(of Anx1 - Anx7);;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Anx_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Anx_miss  > 2 THEN Anx_miss = .;
RUN;
*Note: not all are normal;
PROC UNIVARIATE DATA = Quest_clean;
VAR AnxTot;
HISTOGRAM AnxTot;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE AnxTot Anx1 - Anx7; 
RUN;
DATA Quest_clean;
SET Quest_clean;
AnxTot_rev = 4 + 1 - AnxTot;
AnxTot_log = log(AnxTot_rev);
AnxTot_Log10 = log10(AnxTot_rev);
AnxTot_sq = AnxTot**2;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR AnxTot AnxTot_log AnxTot_Log10 AnxTot_sq;
HISTOGRAM AnxTot AnxTot_log AnxTot_Log10 AnxTot_sq;
RUN;
*Probably just go with the original even though it is skewed;



*Hygiene;
DATA Quest_clean;
SET Quest_clean;
IF HygTeeth = -99 THEN HygTeeth = .;
IF HygShow = -99 THEN HygShow = .;
IF HygRoom = -99 THEN HygRoom = .;
IF HygBed = -99 THEN HygBed = .;
IF HygLaund = -99 THEN HygLaund = .;
IF HygShirt = -99 THEN HygShirt = .;
IF HygJean = -99 THEN HygJean = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE HygTeeth HygShow HygRoom HygBed HygLaund HygShirt HygJean;
RUN;
PROC STANDARD DATA = Quest_clean MEAN = 0 STD =1
              OUT = Quest_clean;
			  VAR HygTeeth HygShow HygRoom HygBed HygLaund HygShirt HygJean;
RUN;
PROC MEANS DATA = Quest_clean;
VAR HygTeeth HygShow HygRoom HygBed HygLaund HygShirt HygJean;
RUN;
DATA Quest_clean;
SET Quest_clean;
Hyg = mean(HygTeeth, HygShow, HygRoom, HygBed, HygLaund, HygShirt, HygJean);
Hyg_miss = cmiss(HygTeeth, HygShow, HygRoom, HygBed, HygLaund, HygShirt, HygJean);
RUN;
PROC Freq DATA = Quest_clean;
TABLE Hyg_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Hyg_miss  > 2 THEN Hyg_miss = .;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VARIABLE HygTeeth HygShow HygRoom HygBed HygLaund HygShirt HygJean; 
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR Hyg HygTeeth HygShow HygRoom HygBed HygLaund HygShirt HygJean;
HISTOGRAM Hyg HygTeeth HygShow HygRoom HygBed HygLaund HygShirt HygJean;
RUN;



*NEO;
DATA Quest_clean;
SET Quest_clean;
IF NEO1 = -99 THEN NEO1 = .;   IF NEO2 = -99 THEN NEO2 = .;   IF NEO3 = -99 THEN NEO3 = .;  
IF NEO4 = -99 THEN NEO4 = .;   IF NEO5 = -99 THEN NEO5 = .;   IF NEO6 = -99 THEN NEO6 = .;  
IF NEO7 = -99 THEN NEO7 = .;   IF NEO8 = -99 THEN NEO8 = .;   IF NEO9 = -99 THEN NEO9 = .;  
IF NEO10 = -99 THEN NEO10 = .;
RUN;
DATA Quest_clean;
SET Quest_clean;
NEO6 = 8 - NEO6;
NEO2 = 8 - NEO2;
NEO8 = 8 - NEO8;
NEO9 = 8 - NEO9;
NEO10 = 8 - NEO10;
RUN;
PROC Freq DATA = Quest_clean;
TABLE  NEO1 - NEO10;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR NEO1 - NEO10;
RUN;
DATA Quest_clean;
SET Quest_clean;
NEOExt = mean(NEO1, NEO6);
NEOExt_miss = cmiss(NEO1, NEO6);

NEOAgre = mean(NEO2, NEO7);
NEOAgre_miss = cmiss(NEO2, NEO7);

NEOCon = mean(NEO3, NEO8);
NEOCon_miss = cmiss(NEO3, NEO8);

NEONeu = mean(NEO4, NEO9);
NEONeu_miss = cmiss(NEO4, NEO9);

NEOOpen = mean(NEO5, NEO10);
NEOOpen_miss = cmiss(NEO5, NEO10);
RUN;
PROC Freq DATA = Quest_clean;
TABLE NEOExt_miss  NEOAgre_miss  NEOCon_miss  NEONeu_miss  NEOOpen_miss;
RUN;
PROC Freq DATA = Quest_clean;
TABLE  NEOExt NEOAgrE NEOCon NEONeu NEOOpen;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF NEOExt_miss  > 0 THEN NEOExt = .;
IF NEOAgre_miss  > 0 THEN NEOAgre = .;
IF NEOCon_miss  > 0 THEN NEOCon = .;
IF NEONeu_miss  > 0 THEN NEONeu = .;
IF NEOOpen_miss  > 0 THEN NEOOpen = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR NEOExt NEOAgrE NEOCon NEONeu NEOOpen;
HISTOGRAM NEOExt NEOAgrE NEOCon NEONeu NEOOpen;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE NEOExt NEOAgrE NEOCon NEONeu NEOOpen; 
RUN;



*Random;
DATA Quest_clean;
SET Quest_clean;
IF InstrumentQuant = -99 THEN InstrumentQuant = .;   
IF InstrumentAcad = -99 THEN InstrumentAcad = .;   
IF VegDiet        = -99 THEN VegDiet = .;  
IF VegReas        = -99 THEN VegReas= .;   
IF ReadFreq       = -99 THEN ReadFreq = .;   
IF ReadQuant      = -99 THEN ReadQuant = .;   
IF NewsFreq       = -99 THEN NewsFreq = .;   
IF NewsQuant      = -99 THEN NewsQuant = .;   
RUN;
PROC Freq DATA = Quest_clean;
TABLE  
InstrumentQuant
InstrumentAcad 
VegDiet        
VegReas        
ReadFreq       
ReadQuant      
NewsFreq       
NewsQuant;      
RUN;
DATA Quest_clean;
SET Quest_clean;
IF InstrumentQuant > 2 THEN Instr = 1;
IF InstrumentQuant < 3 THEN Instr = 0;
IF InstrumentAcad = 1 THEN Instr = .;

IF VegDiet ne 1 THEN Veg = 1;
IF VegDiet = 1 THEN Veg = 0;
IF VegReas = 5 THEN Veg = .;

IF ReadFreq > 2 THEN Read = 1;
IF ReadFreq = 1 THEN Read = 0;
IF ReadFreq = 2 THEN Read = 0;

IF NewsFreq > 1 THEN News = 1;
IF NewsFreq = 1 THEN News = 0;
RUN;
PROC Freq DATA = Quest_clean;
TABLE  
Instr
Veg
Read
News
NewsQuant;
RUN;



*Lifesat;
DATA Quest_clean;
SET Quest_clean;
IF Lifesat1 = -99 THEN Lifesat1 = .;   IF Lifesat2 = -99 THEN Lifesat2 = .;   IF Lifesat3 = -99 THEN Lifesat3 = .;  
IF Lifesat4 = -99 THEN Lifesat4 = .;   IF Lifesat5 = -99 THEN Lifesat5 = .;
RUN;
PROC Freq DATA = Quest_clean;
TABLE  Lifesat1 - Lifesat5;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Lifesat1 - Lifesat5;
RUN;
DATA Quest_clean;
SET Quest_clean;
Lifesat = mean(of Lifesat1 - Lifesat5);
Lifesat_miss = cmiss(Lifesat1 - Lifesat5);
RUN;
PROC Freq DATA = Quest_clean;
TABLE Lifesat_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF LifesatExt_miss  > 1 THEN LifesatExt = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR Lifesat;
HISTOGRAM Lifesat;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE Lifesat Lifesat1 - Lifesat5; 
RUN;
*Is it worth trying to transform?;


*Meaning;
DATA Quest_clean;
SET Quest_clean;
IF Meaning1 = -99 THEN Meaning1 = .; 
IF Meaning4 = -99 THEN Meaning4 = .;   
IF Meaning5 = -99 THEN Meaning5 = .;   
IF Meaning6 = -99 THEN Meaning6 = .;  
IF Meaning9 = -99 THEN Meaning9 = .;  
RUN;
DATA Quest_clean;
SET Quest_clean;
Meaning9 = 8 - Meaning9;
RUN;
PROC Freq DATA = Quest_clean;
TABLE Meaning1 Meaning4 Meaning5 Meaning6 Meaning9;
RUN;
PROC CORR DATA = Quest_clean Alpha NoMiss;
VAR Meaning1 Meaning4 Meaning5 Meaning6 Meaning9;
RUN;
DATA Quest_clean;
SET Quest_clean;
Meaning = mean(Meaning1, Meaning4, Meaning5, Meaning6, Meaning9);
Meaning_miss = cmiss(Meaning1, Meaning4, Meaning5, Meaning6, Meaning9);
RUN;
PROC Freq DATA = Quest_clean;
TABLE  Meaning_miss;
RUN;
DATA Quest_clean;
SET Quest_clean;
IF Meaning_miss  > 1 THEN Meaning = .;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR Meaning;
HISTOGRAM Meaning;
RUN;
*Associations;
PROC CORR DATA = Quest_clean;
VARIABLE Meaning Meaning1 Meaning4 Meaning5 Meaning6 Meaning9; 
RUN;

*****************************************************Code Originally in the analyses program*******************************;

************************************************************************************************************************;
*******************************************************Wrangling and Cleaning*******************************************;
************************************************************************************************************************;
/*
PROC UNIVARIATE DATA = Quest_clean;
VAR FreqQuantDay FreqQuantEnd GameQuantDayTot GameQuantEndTot PhonePath SexRisk PhoneTime DietDys BMI;
HISTOGRAM FreqQuantDay FreqQuantEnd GameQuantDayTot GameQuantEndTot PhonePath SexRisk PhoneTime DietDys BMI;
RUN;
PROC FREQ DATA = Quest_clean;
TABLE Sex;
RUN;
*/
*****
*Computing TV and Game weekly hour average;
*Computing mood change variable;
*Reversing some variables;
*Computing the three DV factors;
*Removing Ps without enough variables for the factors;
*Dummy coding sex so that it's numeric for Proc Reg;
DATA Quest_clean;
SET Quest_clean;

Game = GameQuantDayTot;
TV = FreqQuantDay;

Game = Game * -1;
TV = TV * -1;
BMI = BMI * -1;
*PhonePath = PhonePath * -1;
PhoneTime = PhoneTime * -1;
DietDys = DietDys * -1;
RUN;
/*Checks;
PROC CORR DATA = Quest_clean;
VAR 
GamePathScore GamePathScore2 GamePathScore3
TV TV2 TV3;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR  GamePathScore GamePathScore2 GamePathScore3;
HISTOGRAM GamePathScore GamePathScore2 GamePathScore3;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR TV TV2 TV3;
HISTOGRAM TV TV2 TV3;
RUN;
*/
PROC EXPORT DATA = Quest_clean
			OUTFILE = "C:\Users\Curt\Box Sync\Bruce Projects\Dissertation\Data\Quest_Final_AllVarForDescriptives.txt"
			DBMS = tab
			REPLACE;
			RUN;
DATA Quest_clean;
SET Quest_clean;
KEEP
Subject

Sex Race_cat Age ReligionCat ReligionDegree PolCat PolDeg
UPPS UPPS_NegUrg  UPPS_Prem  UPPS_Pers  UPPS_Sens  UPPS_PosUrg
DelGrat BriefSC 
SocDes
SES SESEduFath SESEduMoth SESFamInc SESSelfRep 

SchoolStrat SchoolEng  SchoolEff SchoolGPA ACTTot
ExerciseReport BMI
DietDys Fat PFaTOverall  DietSingle
Buy FinWB MoneyCons CreditCard 
Sleep
SexRisk 
Game GamePathScore
TV
PhonePath PhoneTime
RelatAccNoLoy 
RelatSat RelatEver  RelatQuant  RelatDur  RelatMar  RelatCurr  RelatDurCurr CheatYN
WorkStat WorkPresTot WorkPres WorkAbs1 WorkAbs2 WorkAbs3 WorkAbs4 
LeisureToT  LeisureTot2  LeisureAwar  LeisureBor  LeisureChal  LeisureDist
AggTot AggPhy AggVerb AggHost AggAng
Smoking
DepTot
AnxTot
Hyg
NEOExt NEOAgrE NEOCon NEONeu NEOOpen
Instr Veg Read News NewsQuant
Lifesat
Meaning
RUN;
/*
PROC FREQ DATA = Quest_clean;
TABLES Inhibition_miss;
RUN;
PROC UNIVARIATE DATA = Quest_clean;
VAR TV Game PhonePath SexRisk PhoneTime DietDys BMI;
HISTOGRAM TV Game PhonePath SexRisk PhoneTime DietDys BMI;
RUN;
PROC FREQ DATA = Quest_clean;
TABLES MentalHealth_miss Problems_miss Health_miss;
RUN;
PROC UNIVARIATE DATA = Quest_clean NOPRINT;
VAR MentalHealth Problems Health Inhib;
HISTOGRAM MentalHealth Problems Health Inhib;
RUN;
*/

*****Duplicate Test;
PROC SORT DATA = Quest_clean;
BY Subject;
RUN;
PROC FREQ DATA = Quest_clean;
TABLES Subject / NOPRINT OUT = DupList;
RUN;
PROC PRINT DATA = DupList;
WHERE Count > 1;
RUN;

************************************************************************************************************************;
*******************************************************Exporting*******************************************;
************************************************************************************************************************;
PROC EXPORT DATA = Quest_clean
			OUTFILE = "C:\Users\Curt\Box Sync\Bruce Projects\Dissertation\Data\Quest_Final.txt"
			DBMS = tab
			REPLACE;
			RUN;

************************************************************************************************************************;
*More restrictive for Mplus;
DATA Quest_clean2;
SET Quest_clean;
KEEP
Subject
SchoolStrat SchoolEng  SchoolGPA 
ExerciseReport BMI  
DietDys Fat PFaTOverall  DietSingle
Buy FinWB MoneyCons CreditCard 
Sleep
SexRisk 
TV
PhonePath PhoneTime
LeisureToT2 
AggTot 
DepTot
AnxTot
Hyg
Lifesat
Meaning;
RUN;

DATA Quest_clean2;
SET Quest_clean2;
IF MISSING(SchoolStrat) THEN SchoolStrat = -999;
IF MISSING(SchoolEng) THEN SchoolEng = -999;
IF MISSING(SchoolGPA) THEN SchoolGPA = -999;
IF MISSING(ExerciseReport) THEN ExerciseReport = -999;
IF MISSING(BMI) THEN BMI = -999;
IF MISSING(DietDys) THEN DietDys = -999;
IF MISSING(Fat) THEN Fat = -999;
IF MISSING(PFaTOverall) THEN PFaTOverall = -999;
IF MISSING(DietSingle) THEN DietSingle = -999;
IF MISSING(Buy) THEN Buy = -999;
IF MISSING(FinWB) THEN FinWB = -999;
IF MISSING(MoneyCons) THEN MoneyCons = -999;
IF MISSING(CreditCard) THEN CreditCard = -999;
IF MISSING(Sleep) THEN Sleep = -999;
IF MISSING(SexRisk) THEN SexRisk = -999;
IF MISSING(TV) THEN TV = -999;
IF MISSING(PhonePath) THEN PhonePath = -999;
IF MISSING(PhoneTime) THEN PhoneTime = -999;
IF MISSING(LeisureToT2) THEN LeisureToT2 = -999;
IF MISSING(AggTot) THEN AggTot = -999;
IF MISSING(DepTot) THEN DepTot = -999;
IF MISSING(AnxTot) THEN AnxTot = -999;
IF MISSING(Hyg) THEN Hyg = -999;
IF MISSING(Lifesat) THEN Lifesat = -999;
IF MISSING(Meaning) THEN Meaning = -999;
RUN;

PROC EXPORT DATA = Quest_clean2
			OUTFILE = "C:\Users\cdvrmd\Box Sync\Bruce Projects\Dissertation\Data\Quest_Final_EFACFA.txt"
			DBMS = tab
			REPLACE;
			RUN;


****************************************************************;
***************************Mplus2 8/22-2018*****************************;
****************************************************************;
DATA Quest_clean2;
SET Quest_clean;
KEEP
Subject
Buy MoneyCons FinWB 
ExerciseReport Fat PFaTOverall DietSingle BMI Hyg Sleep
TV GamePathScore PhoneTime PhonePath
Lifesat Meaning LeisureToT2 DepTot AnxTot AggTot DietDys
RelatSat RelatAccNoLoy 
SchoolEng SchoolStrat SchoolGPA ACTTot
WorkPresTot;
RUN;

DATA Quest_clean2;
SET Quest_clean2;
IF MISSING(SchoolStrat) THEN SchoolStrat = -999;
IF MISSING(SchoolEng) THEN SchoolEng = -999;
IF MISSING(SchoolGPA) THEN SchoolGPA = -999;
IF MISSING(ExerciseReport) THEN ExerciseReport = -999;
IF MISSING(BMI) THEN BMI = -999;
IF MISSING(DietDys) THEN DietDys = -999;
IF MISSING(Fat) THEN Fat = -999;
IF MISSING(PFaTOverall) THEN PFaTOverall = -999;
IF MISSING(DietSingle) THEN DietSingle = -999;
IF MISSING(Buy) THEN Buy = -999;
IF MISSING(FinWB) THEN FinWB = -999;
IF MISSING(MoneyCons) THEN MoneyCons = -999;
IF MISSING(Sleep) THEN Sleep = -999;
IF MISSING(TV) THEN TV = -999;
IF MISSING(PhonePath) THEN PhonePath = -999;
IF MISSING(PhoneTime) THEN PhoneTime = -999;
IF MISSING(LeisureToT2) THEN LeisureToT2 = -999;
IF MISSING(AggTot) THEN AggTot = -999;
IF MISSING(DepTot) THEN DepTot = -999;
IF MISSING(AnxTot) THEN AnxTot = -999;
IF MISSING(Hyg) THEN Hyg = -999;
IF MISSING(Lifesat) THEN Lifesat = -999;
IF MISSING(Meaning) THEN Meaning = -999;
IF MISSING(ACTTot) THEN ACTTot = -999;
IF MISSING(WorkPresTot) THEN WorkPresTot = -999;
IF MISSING(RelatSat) THEN RelatSat = -999;
IF MISSING(RelatAccNoLoy) THEN RelatAccNoLoy = -999;
IF MISSING(GamePathScore) THEN GamePathScore = -999;
RUN;

PROC EXPORT DATA = Quest_clean2
			OUTFILE = "C:\Users\Curt\Box Sync\Bruce Projects\Dissertation\Data\Quest_Final_EFACFA_8-22-2018.txt"
			DBMS = tab
			REPLACE;
			RUN;

/*
PROC UNIVARIATE DATA = Quest_clean2 NOPRINT;
VAR 	
Subject
SchoolStrat SchoolEng  SchoolGPA 
ExerciseReport BMI  
DietDys Fat PFaTOverall  DietSingle
Buy FinWB MoneyCons CreditCard 
Sleep
SexRisk 
TV
PhonePath PhoneTime
LeisureToT2 
AggTot 
DepTot
AnxTot
Hyg
Lifesat
Meaning;
HISTOGRAM 
Subject
SchoolStrat SchoolEng  SchoolGPA 
ExerciseReport BMI  
DietDys Fat PFaTOverall  DietSingle
Buy FinWB MoneyCons CreditCard 
Sleep
SexRisk 
TV
PhonePath PhoneTime
LeisureToT2 
AggTot 
DepTot
AnxTot
Hyg
Lifesat
Meaning;
RUN;
*/
