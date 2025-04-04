/* Import the data */
data migraine;
input Participant_ID $ Sleep_Quality_Group $ Water_Intake $ Migraine_Frequency Migraine_Intensity;
datalines;
P01 High 2_liters 2 3.64
P02 High 2_liters 0 0.00
P03 High 2_liters 1 3.00
P04 High 2_liters 1 4.00
P05 High 2_liters 3 4.36
P06 High 2_liters 2 3.03
P07 High 2_liters 1 5.00
P08 High 2_liters 0 0.00
P09 High 2_liters 1 4.29
P10 High 2_liters 1 3.35
P11 High 2_liters 2 4.50
P12 High 2_liters 1 3.00
P01 High 0.5_liters 3 5.87
P02 High 0.5_liters 2 4.28
P03 High 0.5_liters 1 4.68
P04 High 0.5_liters 0 0.00
P05 High 0.5_liters 4 5.85
P06 High 0.5_liters 2 5.75
P07 High 0.5_liters 1 4.00
P08 High 0.5_liters 3 5.32
P09 High 0.5_liters 2 5.63
P10 High 0.5_liters 6 5.11
P11 High 0.5_liters 1 5.00
P12 High 0.5_liters 1 4.00
P01 Low 2_liters 3 6.19
P02 Low 2_liters 3 7.79
P03 Low 2_liters 3 7.80
P04 Low 2_liters 4 7.27
P05 Low 2_liters 1 6.50
P06 Low 2_liters 3 6.70
P07 Low 2_liters 3 7.45
P08 Low 2_liters 3 7.79
P09 Low 2_liters 5 7.77
P10 Low 2_liters 1 7.00
P11 Low 2_liters 1 7.50
P12 Low 2_liters 4 6.17
P01 Low 0.5_liters 6 8.80
P02 Low 0.5_liters 6 8.21
P03 Low 0.5_liters 4 7.02
P04 Low 0.5_liters 3 7.20
P05 Low 0.5_liters 5 8.33
P06 Low 0.5_liters 5 7.01
P07 Low 0.5_liters 2 7.32
P08 Low 0.5_liters 1 8.00
P09 Low 0.5_liters 3 8.38
P10 Low 0.5_liters 6 8.30
P11 Low 0.5_liters 4 7.45
P12 Low 0.5_liters 3 7.32
;
run;

/* Create formats for better output presentation */
proc format;
  value $sleep_fmt
    'High' = 'High Sleep Quality'
    'Low'  = 'Low Sleep Quality';
  value $water_fmt
    '2_liters'   = 'Adequate Water Intake'
    '0.5_liters' = 'Inadequate Water Intake';
run;

/* Basic descriptive statistics by condition */
proc means data=migraine n mean std min max maxdec=2;
  class Sleep_Quality_Group Water_Intake;
  var Migraine_Frequency Migraine_Intensity;
  format Sleep_Quality_Group $sleep_fmt. Water_Intake $water_fmt.;
  title "Descriptive Statistics for Migraine Study";
run;

/* Box plots for visual inspection */
proc sgplot data=migraine;
  vbox Migraine_Frequency / category=Sleep_Quality_Group group=Water_Intake;
  xaxis label="Sleep Quality Group";
  yaxis label="Migraine Frequency";
  title "Distribution of Migraine Frequency by Sleep Quality and Water Intake";
run;

proc sgplot data=migraine;
  vbox Migraine_Intensity / category=Sleep_Quality_Group group=Water_Intake;
  xaxis label="Sleep Quality Group";
  yaxis label="Migraine Intensity";
  title "Distribution of Migraine Intensity by Sleep Quality and Water Intake";
run;

/* Test for normality */
proc univariate data=migraine normal plots;
  class Sleep_Quality_Group Water_Intake;
  var Migraine_Frequency Migraine_Intensity;
  title "Normality Tests for Migraine Measures";
run;

/* Repeated Measures ANOVA for Migraine Frequency */
proc mixed data=migraine;
  class Participant_ID Sleep_Quality_Group Water_Intake;
  model Migraine_Frequency = Sleep_Quality_Group Water_Intake 
        Sleep_Quality_Group*Water_Intake / ddfm=kr;
  random Participant_ID;
  lsmeans Sleep_Quality_Group*Water_Intake / diff adjust=tukey;
  title "Repeated Measures Analysis for Migraine Frequency";
run;

/* Repeated Measures ANOVA for Migraine Intensity */
proc mixed data=migraine;
  class Participant_ID Sleep_Quality_Group Water_Intake;
  model Migraine_Intensity = Sleep_Quality_Group Water_Intake 
        Sleep_Quality_Group*Water_Intake / ddfm=kr;
  random Participant_ID;
  lsmeans Sleep_Quality_Group*Water_Intake / diff adjust=tukey;
  title "Repeated Measures Analysis for Migraine Intensity";
run;

/* Correlation analysis within subjects */
proc sort data=migraine;
  by Participant_ID;
run;

proc corr data=migraine pearson spearman plots=matrix;
  by Participant_ID;
  var Migraine_Frequency Migraine_Intensity;
  title "Within-Subject Correlation Analysis";
run;

/* Calculate effect sizes using proc mixed */
proc mixed data=migraine method=reml;
  class Participant_ID Sleep_Quality_Group Water_Intake;
  model Migraine_Frequency = Sleep_Quality_Group Water_Intake 
        Sleep_Quality_Group*Water_Intake / solution;
  random Participant_ID;
  ods output SolutionF=fixed Tests3=tests;
  title "Effect Size Analysis for Migraine Frequency";
run;

/* Create summary report */
ods pdf file="migraine_study_results.pdf";

/* Descriptive statistics */
proc means data=migraine n mean std min max maxdec=2;
  class Sleep_Quality_Group Water_Intake;
  var Migraine_Frequency Migraine_Intensity;
  format Sleep_Quality_Group $sleep_fmt. Water_Intake $water_fmt.;
run;

/* Final repeated measures analysis */
proc mixed data=migraine;
  class Participant_ID Sleep_Quality_Group Water_Intake;
  model Migraine_Frequency Migraine_Intensity = Sleep_Quality_Group Water_Intake 
        Sleep_Quality_Group*Water_Intake / ddfm=kr;
  random Participant_ID;
  lsmeans Sleep_Quality_Group*Water_Intake / diff adjust=tukey;
run;

ods pdf close;
