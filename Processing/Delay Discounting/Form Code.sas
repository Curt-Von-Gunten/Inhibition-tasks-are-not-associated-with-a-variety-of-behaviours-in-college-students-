
PROC IMPORT OUT= WORK.DelDis 
            DATAFILE= "C:\Users\Curt\Box Sync\Bruce Projects\Dissertation\Data\Delay Discounting\Delay Discounting Task_March 21, 2018.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


*Dropping unneeded variables;
DATA DelDis_Form (KEEP = Subject_Number_ Start_Date Overall__my_mood_is_____10_repr k_value ED50);
SET DelDis;
Subject = Subject_Number_;
Mood1 = Overall__my_mood_is_____10_repr; 
RUN;
*Renaming variables;
DATA DelDis_Form;
SET DelDis_Form;
Subject = Subject_Number_;
Mood1 = Overall__my_mood_is_____10_repr; 
DROP Subject_Number_ Overall__my_mood_is_____10_repr;
RUN;
*Removing variables;
DATA DelDis_Form;
SET DelDis_Form;
IF Subject = 666 THEN DELETE;
IF Subject = 667 THEN DELETE;
IF Subject = 200 THEN DELETE;
IF Subject = "LR" THEN DELETE;
IF Subject = "XXX" THEN DELETE;
IF Subject = "me" THEN DELETE;
IF Subject = 777 THEN DELETE;
IF Subject = 14228104 THEN DELETE;
IF Subject = "Test_NoD" THEN DELETE;
IF Subject = "Test_All" THEN DELETE;
IF Subject = "Test_One" THEN DELETE;
IF Mood1 = "-" THEN Mood1 = .;
IF MISSING(Mood1) THEN Mood1 = .;
RUN;

*Duplicates;
PROC SORT DATA = DelDis_Form;
BY Subject;
RUN;
PROC FREQ DATA = DelDis_Form;
TABLES Subject / NOPRINT OUT = DupList;
RUN;
PROC PRINT DATA = DupList;
WHERE Count > 1;
RUN;
PROC SORT DATA = DelDis_Form;
BY Subject;
RUN;
DATA DelDis_Form;
SET DelDis_Form;
IF Subject = 85 and k_value = 0.116642369 THEN DELETE;
IF Subject = 117 and k_value = 0.006705787 THEN Subject = 67;
IF Subject = 337 and k_value = 0.039551962 THEN Subject = 338;
Subject_num = Subject + 0;
DROP Subject
RUN;
DATA DelDis_Form;
SET DelDis_Form;
Subject= Subject_num;
DROP Subject_num;
RUN;
PROC SORT DATA = DelDis_Form;
BY Subject;
RUN;
PROC FREQ DATA = DelDis_Form;
TABLES Subject / NOPRINT OUT = DupList;
RUN;
PROC PRINT DATA = DupList;
WHERE Count > 1;
RUN;
PROC SORT DATA = DelDis_Form;
BY Subject;
RUN;

*Descriptives;
/*
PROC UNIVARIATE DATA = DelDis_Form;
HISTOGRAM ED50;
RUN;
PROC FREQ DATA = DelDis_Form;
TABLE ED50;
RUN;
DATA DelDis_Form2;
SET DelDis_Form;
IF ED50 > 3578 THEN ED50 = 3578;
RUN;
PROC UNIVARIATE DATA = DelDis_Form2;
VAR ED50;
HISTOGRAM ED50;
RUN;
DATA DelDis_Form3;
SET DelDis_Form;
IF ED50 > 1350 THEN ED50 = 1350;
RUN;
PROC UNIVARIATE DATA = DelDis_Form3;
VAR ED50;
HISTOGRAM ED50;
RUN;
PROC FREQ DATA = DelDis_Form4;
TABLE ED50;
RUN;
DATA DelDis_Form4;
SET DelDis_Form;
IF ED50 > 480 THEN ED50 = 480;
RUN;
PROC UNIVARIATE DATA = DelDis_Form4;
VAR ED50;
HISTOGRAM ED50;
RUN;
PROC FREQ DATA = DelDis_Form4;
TABLE ED50;
RUN;
*/

*Log transform;
DATA DelDis_Form;
SET DelDis_Form;
ED50_log = log(ED50);
RUN;
PROC UNIVARIATE DATA = DelDis_Form;
HISTOGRAM ED50_log;
RUN;
PROC FREQ DATA = DelDis_Form;
TABLE ED50_log;
RUN;

*Computing ordinal bins;
DATA DelDis_Form;
SET DelDis_Form;
IF ED50 =< 25.283196 THEN ED50_ord = 1;
IF ED50 > 25.283196 and ED50 =< 74.56246777 THEN ED50_ord = 2;
IF ED50 > 74.56246777 and ED50 <= 298.2376234 THEN ED50_ord = 3;
IF ED50 > 298.2376234 and ED50 < 2310.043831 THEN ED50_ord = 4;
IF ED50 => 2310.043831 THEN ED50_ord = 5;
RUN;
PROC UNIVARIATE DATA = DelDis_Form;
VAR ED50_ord;
HISTOGRAM ED50_ord;
RUN;
PROC FREQ DATA = DelDis_Form;
TABLE ED50_ord;
RUN;


PROC EXPORT DATA= WORK.DelDis_Form
            OUTFILE= "C:\Users\Curt\Box Sync\Bruce Projects\Dissertation\Data\Delay Discounting\DelDis_Form.txt" 
            DBMS=TAB 
			REPLACE;
RUN;
