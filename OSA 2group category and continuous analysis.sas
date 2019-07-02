LIBNAME research 'D:\��s��\�p�e���\OSA �z�˭p�e\��Ƥ��R';

/*
Proc format: �����O�̦n�g�{�����̫e��

�ت�: �ŧi��l��� coding value���N�q, �̫᪺����N���ݭn�A���s��g, ²���K
�`�N:  value ���ܶ��W�ٳ̫᭱, ���i�H�O�Ʀr!!�o�OSAS���t�򪺳W�w
*/

Proc Format;
value OSA 0 = 'negative'
                   1= 'positive'
				   2 = 'positive'
				   3 = 'positive'
				   ;

value Age_g 0 = '<50'
					1 = '51-60'
                    2 = '61-70'
                    3 = '71-80'
					;
 
 value Sex 0 ='Female'
                 1='Male'
				  ;

value Marry 0 ='Unmarried'
					1 = 'Married'
					2 = 'Widow'
					3 = 'Divorced'
					;

value Hbp 0 = 'No'
				 1= 'Yes'
				 ;

value Hbp_d 0 = 'No'
				 	 1= 'Yes'
					  ;

value  Diabetes 0 = 'No'
				   		 1= 'Yes'
				         ;

value Diabetes_d 0 = 'No'
				 		   	1= 'Yes'
						   	;

value HD 0 = 'No'
				 1= 'Yes'
				 ;

value HD_d 0 = 'No'
				    1= 'Yes'
					 ;

value  Hyperlip 0 = 'No'
				   		 1= 'Yes'
				         ;

value Hyperlip_d 0 = 'No'
				 		   	1= 'Yes'
						   	;

value Education 0 = 'Illiteracy'
						  1 = 'Elelmentary'
						  2 = 'Junior_high'
						  3 = 'High'
						  4 = 'Vocational high'
						  5 = 'University'
						  6 = 'Junoir college'
						  7 = 'Master'
						  8 = 'Doctor'
						  ;
value BMI;
value Waist; 
value Neck; 
value PSQI ;
value ESS ;
value TMT_A; 
value TMT_B ;
value MMSE ;
value MMSE_A; 
value MMSE_B ;
value MMSE_C ;
value MMSE_D ;
value MMSE_E ;
		    ; 
data a0;   /*�Ȧs��, �ɦWa0*/
set research.osa2;   
run;
/*�p�G�Y�_�{���X�� �ݭn�s�U�@�檺�Ů�@�_�ϥ� �~�|�����q�{�� �_�h�u�|����Ĥ@��*/

data a1; set a0;

%inc 'D:\��s��\�p�e���\OSA �z�˭p�e\��Ƥ��R\OSA statistic table condition.sas';
if age > 80  then delete;
if age = 80 then age_g = 3;
 /* �q�ۤv�����| �I�s�����ɮ�  ���ɮץ����S��run�����O*/
run;
proc contents data=a1;run;
/*
�T�w�ݬݯण�ন�\�[�H�����:
*/

/*�Υ������O MACRO �@�έp���i���: �]�A���O�ܶ��B�s���ܶ���j�����y�z�έp��, �H�Τ��R�έp��
 
I. �y�z�έp��: ���O��ƪ� (�d���˩w, �|�P�U�����s���ܶ��X���@�Ӫ�)
   �ɥR�����G
�@(1). %macro categ(pred, i): �������O %macro categ, �����ܶ����, �]�N�O�A������ pred, i  
    (2). %mend: �������O�פ�;  mend �N�Omacro end���N��
    (3). %�Ÿ��᭱���������O; &�Ÿ��᭱�������ܶ�
*/

/*
Step 1-Generate source datasets for cell counts by group and p-value: 
*/

%macro categ(pred,i);  /*��ӥ����ܶ�, */

proc freq data =a1;
where OSA^=. and &pred ^=.;                                               /*missing ���ݭn�p��; �`�N: ���n�g��  where hiv ne. and &pred ne.*/
  *hiv����l���(hiv.sas_demo_msm2009)�����ܶ� 0 = negative ,1= postive;                
tables &pred*OSA / chisq sparse outpct out = outfreq&i ;    /*�`�N   tables Xs*Y ������ ; �N������9���ܶ��Mhiv���L���C�s��M�d��A�X���˩w outfreq1~9*/
*sparse ��X�ܬ۪��Ȫ��Ҧ��զX, outpct �p���B�C�B���`�ʤ���;
output out = stats&i chisq; *��X��stats1~9;
run;
*OUTPUT �ԭz�y�G�i���XPROC freq�p��X���S�w���d��έp�ȩ�PROC �]�X���Ҧ��ȡA�Ϩ䦨���s����ƶ�(data set)�C
OUT= ���O�G���������J���إߪ��s��ƶ����W�١C;
proc sort data = outfreq&i; *�Noutfreq1~9���ܶ��Ƨ�;
by &pred;
run;

/*
Step 2a and 2b-Get number and percent by predictor for all
�N�E�����O�����ն��ؤ��O���p��(mountfreqa)�M�ʤ���(mountfreqb)
*/

proc means data = outfreq&i noprint;    /*�Noutfreq1~9���ܶ����Ӽƭp�� n : */
by &pred;
var COUNT;
output out=moutfreqa&i (keep=&pred totala rename=(&pred=variable)) sum=totala;  
run;*�N�Ȧs��outfreq ��W��moutfreqa1~9 �u�O�d pred�����թM total �ñN�Ө��ܶ���W��variable �W��(��pred������)�M total�`��;

proc means data = outfreq&i noprint;  /* �ʤ��� % : �p���ܶ� percent�������ȧY�i */
by &pred;
var PERCENT;
output out=moutfreqb&i (keep=&pred totalb rename=(&pred=variable)) sum=totalb;
run;*�N�Ȧs��outfreq ��W��moutfreqb1~9 ;

/* ????????????? ||& compress 5.2
Step 3-Combine datasets : total 
*/
data moutfreq&i;
merge moutfreqa&i moutfreqb&i;
by variable;*�H�U�ܶ����D�Nmoutfreqa���p�ƩMmoutfreqb���ʤ���X�֦��W�smoutfreq1~9���ɮ�;
*�h��total�Mvarname��columng�ɥR����;
total= compress(totala)	||"("||compress(put((round(totalb,0.01)),5.2))||")";  /* �s�y�X: �Ӽ� (%) ���N��, ��total�p���I�H�U2��*/
*||�걵�Ÿ� ;* COMPRESS (�Ѽ� 1,"�Ѽ� 2")�C�u�Ѽ� 2�v�i�H��m����������r�n�ϥΡu���޸��v�]�q;
*put(source,format)�Ʀr���r;
varname=vlabel(variable);  /*����B�J: varname= �����ܶ����ܶ�Labeling;  �Ҧp, age_g�N�OAge Group... �S�O�`�N, �@�w�n �N&pred �令variable, �]���w�g rename (&pred=variable)�F !!*/ 
run;


/*??????????????
Step 4- number and percent by predictor by hiv
*/

data routfreq&i;
set outfreq&i;
length varname $20.;   /*varname�����׫ŧi���� 20���*/

      rcount = put(count,6.);    /*6���!!*/   *�H�U�T��???? count??;
      rcount = compress(left(rcount));   
      col_pct3= "("||compress(put((round(pct_row,0.01)),5.2))||")";  /*���p���I�H�U2�� pct_col�Hcolumn�p��ʤ��� �Y�Opct_row�Hrow�p��ʤ���*/
      pctnum = rcount||" "||col_pct3;
      varname=vlabel(&pred);    /*����B�J: varname= �����ܶ����ܶ�Labeling;  �Ҧp, age_g�N�OAge Group... �S�O�`�N, �@�w�n�O�d&pred, �]���S�� rename �o�Ӱʧ@!!*/ 
          index=&i;
          variable=&pred;             *�s�ܶ�=���ܶ� variable=&pred;* ,�q����y�z��r�A�ഫ���@�}�l�ҵ��w���Ʀr�s��/ ;
	
/*keep variable pctnum index varname hiv;
run;

proc sort;
by variable;
run;

/*
Step 5-Transpose data into proper configuration 
*/

proc transpose data=routfreq&i out=transp_cate&i prefix=OSA_;                 /*����B: prefix=hiv*/
*prefix ���w�r���Ψӳs���᭱���ܼ�(�e���w�q��_postive �M _negative);
	by variable; *��m���ը̾� (�৹�᪺�Ĥ@��);
	var pctnum; *���w��m�����;
	id OSA;                                                                                                   /*�`�N id hiv ���Ϊk */
	*ID �ܼƦW, �N�a�J���ܶ��ഫ����m�᪺�ܼƦW�� _postive�M_negative�q���誺�C +hiv�r���ܦ��W�誺���?;
run;

/*
Step 6-Obtain p-values
*/

data rstats&i; 
 set stats&i;
length p_value $8.; *PCHI = Pearson chi-square, but P_PCHI????????????;
p_value = put(P_PCHI,8.3);   /*������O�n��b�̫e��, �p�G��bp_pchi<0.001�᭱, �|�]����O�\�e�O, �ӥX�{ p=0.003; p=0.000�����p*/
if 0.001<=P_PCHI < 0.05 then p_value =('<0.05' || '*');
if P_PCHI < 0.001 then p_value =('<0.001' || '**');

keep p_value index;
index =&i;
run;

data _null_; *�إߤ��s�b��dataset Why??????????;
set a1;
call symput("fmt",vformat(&pred));                  /*�s�y�X�@�ӷs�������ܶ� fmt, �N���ŧi���� &pred���ܶ��榡(format), �Ҧp�~���N�O�T��format: <20, 20-40, >=40*/
run;
*�w�q�����ܼ� %LET �ܼƦW�� = �ܼƭ�,  or  call symput;
*call symput(macro�ܼƦW�� , �޼�),�bDATA step���N�ȶ��@��macro�ܼƸ̭�;
/*
ex: %let exa = study; %let�u�൹��ڪ��� 
     call symput (exa, study);
�ϥήɥ�&exa �I�s�X study
*/

/*
Step 7-Merges begin
*/

data temp&i;
merge moutfreq&i transp_cate&i;
by variable;
index=&i;
run;

/*
Step 8-Final Merge
*/


data final_cate&i;
merge temp&i rstats&i;
by index;
all=total;
length formats $20.;  /*�n�[�W�o����O: �_�h���׷|�Q����Ĥ@���ܶ�age_g��5�r�����Τ@��;  */
length p_final $8.;
length statistic $15.;
formats=put(variable,&fmt);                  /*�s�y�X�@�ӷs���ܶ�formats: �n�h �I�s variable (��&pred rename�Ө�!!)�������ܶ� fmt*/
if first.index then statistic='n (%)';         /*�u�n index=1���Ĥ@����ư���U�C���O, �Ҧp: �u�n age_g �O<20 �����@�C�~�ݭn�C�X  n [%]...��L��դ��n, �O���ť� */

if not first.index then do;
		p_value = " ";
		varname=" ";
 end;

p_final=p_value;
*keep varname  statistic all hiv_negative hiv_positive index p_final formats;  /*hiv_negative hiv_positive �ܭ��n, ���d��; �n�O�o��formats keep�U��*/
run;
%mend;
%categ(Age_g,1) %categ(Sex,2) %categ(Marry,3) %categ(Hbp,4) %categ(Hbp_d,5) %categ(Diabetes,6) %categ(Diabetes_d,7) %categ(HD,8) %categ(HD_d,9); %categ(Hyperlip,10) %categ(Hyperlip_d,11) %categ(Education,12);

%macro names(j,k,dataname);
%do i=&j %to &k;
&dataname&i
%end;
%mend names;

data categ_osa_test1;      /*�ʷd��槹��, �u�t���ǻݭn�վ�*/
set %names(1,12,final_cate);                                                            /*12�����O�ܶ��n�令�s�ɮת�P�����O*/
label varname = "Variable"
p_final = "p-value"
formats = "Category";
run;

%macro table (var,i);  /*�ק����ܶ�������: ��1-9�����Ǧۤv�M�w, �`�N: �ܶ��W�٭n�έ�Ӫ��W��, �Ҧp�H�f�ǯS�x�n��varname; category�n��formats...*/
data categ_table&i;
set categ_osa_test1;
keep &var index;
run;
%mend;
%table(varname,1)  %table(formats,2)  %table(statistic,3) %table(OSA_negative,4) %table(OSA_positive,5) %table(all,6) %table(p_final,7) ;

%macro tablenames(j,k,dataname);
%do i=&j %to &k;
&dataname&i
%end;
%mend tablenames;

data categ_table; /*�̲ץ��T���㪺���O��ƴy�z�έp��*/
merge %tablenames(1,7,categ_table);
by index;
drop index;
run;
*���O�ܶ��έp���X;/*
PROC EXPORT DATA= WORK.categ_table 
            OUTFILE= "D:\��s��\�p�e���\OSA �z�˭p�e\��Ƥ��R\OSA_analysis_table.xlsx"
            DBMS=EXCEL REPLACE;
     SHEET1="category"; 
RUN;
*/

/*
II. �y�z�έp��: �s���ƪ� (�|�P�W�������O�ܶ��X���@�Ӫ�)
*/

%macro cont(cpred,i);

/*
STEP 1: Proc means: �o��H�U�έp��
n mean stddev median min max p25 p75
*/


proc means data=a1 ;
class OSA_suffer;
var &cpred;
output out=means&i n=n mean=mean stddev=stddev median=median min=min max=max p25=p25 p75=p75 ; /*n �Q�ܶ��W�ٻ\��, �����|�v�T�̫ᵲ�G!*/
run;

data vertical&i ; 
set means&i;
medianb=compress(put((round(median,0.01)),5.2));
minmax="("||compress(put((round(min,0.01)),5.2))||", "||compress(put((round(max,0.01)),5.2))||")";
meansd=compress(put((round(mean,0.01)),5.2))||" ("||compress(put((round(stddev,0.01)),5.2))||")";
pctl="("||compress(put((round(p25,0.01)),5.2))||", "||compress(put((round(p75,0.01)),5.2))||")";
keep OSA_suffer n meansd median minmax  pctl; 
run;

/*
��ƥѪ����ন�
*/
proc transpose data=vertical&i out=transp_cont&i ;  /*_NAME_  _NAME_�On, mean, median, minmax*/
var n meansd medianb minmax pctl;
run;

data horizontal&i;
set transp_cont&i;
 /* �o�Ӱʧ@������ varname=vlabel(&cpred); */
run;

*t test �u��ǭǤ�� �]����OSA�Y���ץHAHI = 5������ �ରOSA���L(���condition�ɮ׽վ���ɭ�);

proc ttest data = a1;
class OSA_suffer;
var &cpred;
ods output equality = equalvar&i(keep = probf)
statistics = stat&i(keep = N mean StdDev)
ttests = ttest&i(keep = method variances probt);
run;

/*
STEP 2: Obtain Appropriate P-value for T-Test
   1. ���� Equal variance test
   2. �A�� ��� t test ���G���䤤�@�� p value
*/

data _null_;
set ttest&i;
if method='����' then call symput('probt1',probt);
else if method='Satterthwaite' then call symput('probt2',probt);
run;

data pvalue&i;   /*ttest: �̫�u�np_final*/
set equalvar&i;


if Probf<  0.05 then do;
pvalue = "&probt2";
end;
else if Probf>=0.05 then pvalue = "&probt1";

length p_final $8.;
 
p_final=round(pvalue,0.001); /*�[�W������O, �n��b�̫e��, �p�G��b�᭱, �|�]����O�\�e�O, �ӥX�{ p=0.003; p=0.000�����p*/ 
                                                /*�ΥH�U���ŧi�覡�L��, p_final = put(pvalue, 8.3), �|�X�{�p���I�W�L3�쪺���G, ���I�_��;*/
if 0.001<=pvalue<  0.05 then p_final =('<0.05' ||'*');
if pvalue<0.001 then p_final = ('<0.001' || '**');

keep p_final;  
run;
                                                 
/*
STEP 3: �o��̫��ɮ�
����B�J: statistic, hiv_negative, hiv_positive, ���D�n�ܶ�, ���b�o�ӨB�J�ŧi
*/
data fin&i (rename=(_name_=statistic col1=all col2=OSA_negative col3=OSA_positive )); 
merge horizontal&i pvalue&i;
run;


/*
�ŧi&cpred�ܶ���Labeling
*/
data _null_;
set a1;
call symput('name', vlabel(&cpred));
run;

data fina&i;
 set fin&i;
 length varname $30.;
 varname="&name";  /*VARNAME�Ĥ@���ŧi, �즳���ŧi�覡�Ȯɤ���! */  
run;

/*
�u�n�Ĥ@�ӦC�n�����O p-value, �ܶ�Labeling�Y�i
*/
data final_cont&i;
set fina&i;
by varname;

if first.varname then do;
    varname="&name"; 	 
	index=&i;
    end;
 if not first.varname then do; 
		varname = " ";
		p_final=" ";
 end;
 
label varname='Variable'
         p_final='p-value'
         statistic='statistic';
formats= " ";   /*�s�y�s�ܶ� formats, �⥦�O���ť�, �����O�n�P���O��Ƭ۩I��*/

keep  varname formats  statistic all OSA_negative OSA_positive index p_final;  
run;

%mend cont;
%cont(BMI,1) %cont(Waist,2) %cont(Neck,3) %cont(PSQI,4) %cont(ESS,5) %cont(TMT1,6) %cont(TMT2,7) %cont(MMSE,8) %cont(MMSE_A,9) %cont(MMSE_B,10) %cont(MMSE_C,11) %cont(MMSE_D,12) %cont(MMSE_E,13) ;


%macro namesx(j,k,dataname);
%do i=&j %to &k;
&dataname&i
%end;
%mend namesx;
data cont_table;
set %namesx(1,13,final_cont);                  /*13�ӳs���ܶ��n�令�s�ɮת�Q�ӳs��*/
drop index;
run;

data cont_table1;
set cont_table;
length stat $15.; /*���׭n�b�o�̫ŧi!!!*/
stat=statistic;
if statistic='meansd' then stat='Mean (sd)'; 
if statistic='minmax' then stat='(Min, Max)';
if statistic='pctl' then stat='(25th, 75th)';
if statistic='medianb' then stat='Median';
drop statistic;
run;
data cont_table2;
set cont_table1;
statistic=stat;
drop stat;
run;
*�s���ܶ��έp����X;/*
PROC EXPORT DATA= WORK.cont_table2
            OUTFILE= "D:\��s��\�p�e���\OSA �z�˭p�e\��Ƥ��R\OSA_analysis_table.xlsx"
            DBMS=EXCEL REPLACE;
     SHEET2="continuous"; 
RUN;
*/
/*���է��ܶ���;
data cont_table3;
set cont_table2;
retain varname statistic formats OSA_negative OSA_positive all p_final;
drop formats;
run;
proc print data = cont_table3;
run;
*/

/*�̲״y�z�έp���: */
data cate_cont_table;  
set categ_table cont_table2;
run;

*���O�P�s��έp���X�ֿ�X;/*
PROC EXPORT DATA= WORK.cate_cont_table
            OUTFILE= "D:\��s��\�p�e���\OSA �z�˭p�e\��Ƥ��R\OSA_analysis_table.xlsx"
            DBMS=EXCEL REPLACE;
     SHEET3="all"; 
RUN;
*/
