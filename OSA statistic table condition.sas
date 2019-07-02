if age<50 then age_g=0;
if 50=<age< 60 then age_g=1;
if 60<= age<70 then age_g=2;
if 70<=age<=80 then age_g=3;


IF OSA = 0 then OSA_suffer  = 0;
ELSE IF OSA=1 then OSA_suffer = 1;
ELSE IF OSA=2 then OSA_suffer = 1;
ELSE IF OSA=3 then OSA_suffer = 1;

IF Hbp = 0 and HD = 0 and Hyperlip = 0 then CAD= 0;
*IF Hbp = 1 and HD = 0 and Hyperlip = 0 then CAD = 1;*hypertension ¤À²Õ;
IF Hbp = 1 or HD = 1 or Hyperlip = 1 then CAD= 1;

IF Hbp = 0 and Hbp_d = 0 then HTD = 0;
ELSE IF Hbp = 1 and Hbp_d = 0 then HTD = 1;
ELSE IF Hbp = 1 and Hbp_d = 1 then HTD = 2;

IF Diabetes = 0 and Diabetes_d = 0 then DM = 0;
ELSE IF Diabetes = 1 and Diabetes_d = 0 then DM = 1;
ELSE IF Diabetes = 1 and Diabetes_d = 1 then DM = 2;

IF HD = 0 and HD_d = 0 then HeartD = 0;
ELSE IF HD = 1 and HD_d = 0 then HeartD = 1;
ELSE IF HD = 1 and HD_d = 1 then HeartD = 2;

IF Hyperlip = 0 and Hyperlip_d = 0 then HL = 0;
ELSE IF Hyperlip = 1 and Hyperlip_d = 0 then HL = 1;
ELSE IF Hyperlip = 1 and Hyperlip_d = 1 then HL = 2;

IF PSQI <= 5 then sleep = 0;
IF PSQI > 5 then sleep = 1;

IF ESS < 10 then ESSg = 0;
IF ESS >= 10 then ESSg = 1;

IF ODI2 = . then ODI = ODI1;
ELSE ODI = (ODI1 + ODI2)/2;

IF ODI1 > ODI2 then ODImax = ODI1;
ELSE ODImax = ODI2;

IF ODE2 = . then ODE = ODE1;
ELSE ODE = (ODE1+ODE2)/2;

IF ODE1 > ODE2 then ODEmax = ODE1;
ELSE ODEmax = ODE2;

IF spo2_baseline2 = . then spo2_baseline = spo2_baseline1;
ELSE spo2_baseline = (spo2_baseline1+ spo2_baseline2)/2;

IF spo2_mean2 = . then spo2_mean = spo2_mean1;
ELSE spo2_mean = (spo2_mean1 + spo2_mean2)/2;

IF spo2_lowest2 = . then spo2_lowestmean = spo2_lowest1;
ELSE spo2_lowestmean = (spo2_lowest1 + spo2_lowest2)/2;

IF spo2_lowest1 > spo2_lowest2 then spo2_lowest = spo2_lowest1;
ELSE spo2_lowest = spo2_lowest2;

Label 
		/*category variable*/
		CAD = 'CAD'
		OSA = 'OSA'
		Age_g = 'Age group' 
		Sex = 'Sex'
		Marry = 'Marry'
		Hbp = 'Hypertension'
		Hbp_d = 'Hypertension drug using'
		HTD = 'Hypertension disease'
		Diabetes = 'Diabetes'
		Diabetes_d = 'Diabetes drug using'
		DM = 'Diabetes mellitus'
		HD = 'Heartdisease'
		HD_d = 'Heartdisease drug using'
		HeartD = 'Heart disease'
		Hyperlip = 'Hyperlipidemia'
		Hyperlip_d = 'Hyperlipidemia durg using'
		HL = 'Hyperlipidemia'
		Sleep = 'Sleep quality'
		ESSg = 'Epworth Sleepiness subgroup'
		Education = 'Education'
		/*cont variable*/
		BMI	= 'BMI'
		Waist = 'Waist_cm'	
		Neck = 'Neck_cm'
		PSQI = 'Pittsburgh Sleep Quality Index'
		C1 = 'Subjecive Sleep quality'
		C2 = 'Sleep lactency'
		C3 = 'Sleep duration'
		C4 = 'Habitual sleep efficiency'
		C5 = 'Sleep disturbances'
		C6 = 'Use of sleeping medication'
		C7 = 'Daytime dysfunction'
		ESS	= 'Epworth Sleepiness Scale'
        TMT1 = 'Trail Making Test 1'
		TMT2 = 'Trail Making Test 2'
		MMSE = 'Mini-Mental State Examination'
		MMSE_A = 'MMSE_A- orientation'
		MMSE_B = 'MMSE_B- registration'
		MMSE_C = 'MMSE_C- attention & calculation'
		MMSE_D = 'MMSE_D- short term memory'
		MMSE_E = 'MMSE_E- commands'
		ODI = 'ODI'
		ODImax = 'ODImax'
		ODE = 'ODE'
		ODEmax = 'ODEmax'
		spo2_baseline = 'spo2_baseline'
		spo2_mean = 'spo2_mean'
		spo2_lowestmean = 'spo2_lowestmean ' 
		spo2_lowest = 'spo2_lowest'

		; 

Format OSA OSA.
			Age_g Age_g.
			Sex Sex.
			Marry Marry.
			Hbp Hbp.
			Hbp_d Hbp_d.
			HTD HTD.
			Diabetes Diabetes.
			Diabetes_d Diabetes_d.
			DM DM.
			HD HD.
			HD_d HD_d.
			HeartD HeartD.
			Hyperlip Hyperlip.
			Hyperlip_d Hyperlip_d.
			HL HL.
			ESS_subgroup ESS_subgroup.
			ESSg ESSg.
			Sleep Sleep.
			Education Education.
			CAD CAD.
			; 

			
