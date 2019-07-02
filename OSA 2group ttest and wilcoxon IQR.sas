LIBNAME research 'D:\研究所\計畫資料\OSA 篩檢計畫\資料分析';

/*
Proc format: 本指令最好寫程式的最前面

目的: 宣告原始資料 coding value的意義, 最後的報表就不需要再重新改寫, 簡單方便
注意:  value 的變項名稱最後面, 不可以是數字!!這是SAS很龜毛的規定
*/

Proc Format;
value OSA 0 = 'negative'
                   1= 'negative'
				   2 = 'positive'
				   3 = 'positive'
				   ;

value Age_g 0 = '<50'
					1 = '50-59'
                    2 = '60-69'
                    3 = '70-80'
					;
 
 value Sex 0 ='Female'
                 1= 'Male'
				  ;

value Marry 0 ='Unmarried'
					1 = 'Married'
					2 = 'Widow'
					3 = 'Divorced'
					;

value CAD  0 = 'negative'
				  	1 = 'positive'
				 	 ;

value Hbp 0 = 'No'
				 1= 'Yes'
				 ;

value Hbp_d 0 = 'No'
				 	 1= 'Yes'
					  ;
value HTD 0 = 'No Hypertension'
				  1 = 'Hypertension without durg'
				  2 = 'Hypertension with durg'
				  ;

value  Diabetes 0 = 'No'
				   		 1= 'Yes'
				         ; 

value Diabetes_d 0 = 'No'
				 		   	1= 'Yes'
						   	;

value DM  0 = 'No Diabetes'
				  1 = 'Diabetes without durg'
				  2 = 'Diabetes with durg'
				  ;

value HD 0 = 'No'
				 1= 'Yes'
				 ;

value HD_d 0 = 'No'
				    1= 'Yes'
					 ;

value HeartD 0 = 'No Heart disease'
					  1 = 'Heart disease without drug'
					  2 = 'Heart disease with drug'
					  ;

value  Hyperlip 0 = 'No'
				   		 1= 'Yes'
				         ;

value Hyperlip_d 0 = 'No'
				 		   	1= 'Yes'
						   	;

value HL 0 = 'No Hyperlipidemia'
			   1 = 'Hyperlipidemia without drug'
			   2 = 'Hyperlipidemia with drug'
			   ;

value ESS_subgroup 0 = 'Normal'
								 1 = 'Sleepness'
								 ;

value Sleep 0 = 'good sleeper'
				  1 = 'poor sleeper'
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
data a0;   /*暫存檔, 檔名a0*/
set research.osa;   
run;
/*如果縮起程式碼後 需要連下一行的空格一起反白 才會執行整段程式 否則只會執行第一行*/

data a1; set a0;

%inc 'D:\研究所\計畫資料\OSA 篩檢計畫\資料分析\OSA statistic table condition.sas';
*if Sex = 0 then delete;
if OSA = 1 then delete;
*if OSA = 2 then delete;
if age < 60 then delete;
if age > 80  then delete;
if age = 80 then age_g = 3;
 /* 從自己的路徑 呼叫條件檔案  此檔案本身沒有run的指令*/
run;

proc contents data=a1;run;
/*
確定看看能不能成功加以條件化:
*/

/*用巨集指令 MACRO 作統計報告表格: 包括類別變項、連續變項兩大類的描述統計表, 以及分析統計表
 
I. 描述統計表: 類別資料表 (卡方檢定, 會與下面的連續變項合成一個表)
   補充說明：
　(1). %macro categ(pred, i): 巨集指令 %macro categ, 巨集變項兩個, 也就是括弧內的 pred, i  
    (2). %mend: 巨集指令終止;  mend 就是macro end的意思
    (3). %符號後面接巨集指令; &符號後面接巨集變項
*/

/*
Step 1-Generate source datasets for cell counts by group and p-value: 
*/

%macro categ(pred,i);  /*兩個巨集變項, */

proc freq data =a1;
where OSA^=. and &pred ^=.;                                               /*missing 不需要計算; 注意: 不要寫成  where hiv ne. and &pred ne.*/
  *hiv為原始資料(hiv.sas_demo_msm2009)中的變項 0 = negative ,1= postive;                
tables &pred*OSA / chisq sparse outpct out = outfreq&i ;    /*注意   tables Xs*Y 的順序 ; 將巨集的9個變項和hiv有無做列連表和卡方適合度檢定 outfreq1~9*/
*sparse 輸出變相的值的所有組合, outpct 計算行、列、表的總百分比;
output out = stats&i chisq; *輸出成stats1~9;
run;
*OUTPUT 敘述句：可取出PROC freq計算出的特定的卡方統計值或PROC 跑出的所有值，使其成為新的資料集(data set)。
OUT= 指令：等號之後輸入欲建立的新資料集的名稱。;
proc sort data = outfreq&i; *將outfreq1~9依變項排序;
by &pred;
run;

/*
Step 2a and 2b-Get number and percent by predictor for all
將九個類別的分組項目分別做計數(mountfreqa)和百分比(mountfreqb)
*/

proc means data = outfreq&i noprint;    /*將outfreq1~9個變項的個數計算 n : */
by &pred;
var COUNT;
output out=moutfreqa&i (keep=&pred totala rename=(&pred=variable)) sum=totala;  
run;*將暫存檔outfreq 更名為moutfreqa1~9 只保留 pred的分組和 total 並將該兩變項更名為variable 名稱(比pred的完整)和 total總數;

proc means data = outfreq&i noprint;  /* 百分比 % : 計算變項 percent的平均值即可 */
by &pred;
var PERCENT;
output out=moutfreqb&i (keep=&pred totalb rename=(&pred=variable)) sum=totalb;
run;*將暫存檔outfreq 更名為moutfreqb1~9 ;

/* ????????????? ||& compress 5.2
Step 3-Combine datasets : total 
*/
data moutfreq&i;
merge moutfreqa&i moutfreqb&i;
by variable;*以各變項為主將moutfreqa的計數和moutfreqb的百分比合併成名叫moutfreq1~9的檔案;
*多給total和varname的columng補充說明;
total= compress(totala)	||"("||compress(put((round(totalb,0.01)),5.2))||")";  /* 製造出: 個數 (%) 的意思, 取total小數點以下2位*/
*||串接符號 ;* COMPRESS (參數 1,"參數 2")。「參數 2」可以放置欲移除的文字要使用「雙引號」包裹;
*put(source,format)數字轉文字;
varname=vlabel(variable);  /*關鍵步驟: varname= 解釋變項的變項Labeling;  例如, age_g就是Age Group... 特別注意, 一定要 將&pred 改成variable, 因為已經 rename (&pred=variable)了 !!*/ 
run;


/*??????????????
Step 4- number and percent by predictor by hiv
*/

data routfreq&i;
set outfreq&i;
length varname $30.;   /*varname的長度宣告成為 20欄位*/

      rcount = put(count,6.);    /*6位數!!*/   *以下三行???? count??;
      rcount = compress(left(rcount));   
      col_pct3= "("||compress(put((round(pct_col,0.01)),5.2))||")";  /*取小數點以下2位 pct_col以column計算百分比 若是pct_row以row計算百分比*/
      pctnum = rcount||" "||col_pct3;
      varname=vlabel(&pred);    /*關鍵步驟: varname= 解釋變項的變項Labeling;  例如, age_g就是Age Group... 特別注意, 一定要保留&pred, 因為沒有 rename 這個動作!!*/ 
          index=&i;
          variable=&pred;             *新變項=舊變項 variable=&pred;* ,從完整描述文字再轉換成一開始所給定的數字編組/ ;
	
/*keep variable pctnum index varname hiv;
run;

proc sort;
by variable;
run;

/*
Step 5-Transpose data into proper configuration 
*/

proc transpose data=routfreq&i out=transp_cate&i prefix=OSA_;                 /*關鍵處: prefix=hiv*/
*prefix 指定字首用來連接後面的變數(前面定義的_postive 和 _negative);
	by variable; *轉置分組依據 (轉完後的第一行);
	var pctnum; *指定轉置的欄位;
	id OSA;                                                                                                   /*注意 id hiv 的用法 */
	*ID 變數名, 將帶入的變項轉換成轉置後的變數名稱 _postive和_negative從左方的列 +hiv字首變成上方的欄位?;
run;

/*
Step 6-Obtain p-values
*/

data rstats&i; 
 set stats&i;
length p_value $8.; *PCHI = Pearson chi-square, but P_PCHI????????????;
p_value = put(P_PCHI,8.3);   /*本行指令要放在最前面, 如果放在p_pchi<0.001後面, 會因為後令蓋前令, 而出現 p=0.003; p=0.000的情況*/
if 0.001<=P_PCHI < 0.05 then p_value =('<0.05' || '*');
if P_PCHI < 0.001 then p_value =('<0.001' || '**');

keep p_value index;
index =&i;
run;

data _null_; *建立不存在的dataset Why??????????;
set a1;
call symput("fmt",vformat(&pred));                  /*製造出一個新的巨集變項 fmt, 將之宣告成為 &pred的變項格式(format), 例如年紀就是三種format: <20, 20-40, >=40*/
run;
*定義巨集變數 %LET 變數名稱 = 變數值,  or  call symput;
*call symput(macro變數名稱 , 引數),在DATA step內將值塞到一個macro變數裡面;
/*
ex: %let exa = study; %let只能給實際的值 
     call symput (exa, study);
使用時用&exa 呼叫出 study
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
length formats $30.;  /*要加上這行指令: 否則長度會被原先第一個變項age_g的5字元給統一掉;  */
length p_final $8.;
length statistic $15.;
formats=put(variable,&fmt);                  /*製造出一個新的變項formats: 要去 呼叫 variable (由&pred rename而來!!)的巨集變項 fmt*/
if first.index then statistic='n (%)';         /*只要 index=1的第一筆資料執行下列指令, 例如: 只要 age_g 是<20 的那一列才需要列出  n [%]...其他兩組不要, 保持空白 */

if not first.index then do;
		p_value = " ";
		varname=" ";
 end;

p_final=p_value;
*keep varname  statistic all hiv_negative hiv_positive index p_final formats;  /*hiv_negative hiv_positive 很重要, 易搞錯; 要記得把formats keep下來*/
run;
%mend;
%categ(Age_g,1) %categ(Sex,2) %categ(Marry,3) %categ(CAD,4) %categ(Hbp,5) %categ(HD,6) 
%categ(hyperlip,7) %categ(Diabetes,8) %categ(Sleep,9) %categ(ESS_subgroup,10) %categ(Education,11);

%macro names(j,k,dataname);
%do i=&j %to &k;
&dataname&i
%end;
%mend names;

data categ_osa_test1;      /*粗搞表格完成, 只差順序需要調整*/
set %names(1,10,final_cate);                                                            /*12個類別變項要改成新檔案的P個類別*/
label varname = "Variable"
p_final = "p-value"
formats = "Category";
run;

%macro table (var,i);  /*修改表格變項的順序: 由1-9的順序自己決定, 注意: 變項名稱要用原來的名稱, 例如人口學特徵要用varname; category要用formats...*/
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

data categ_table; /*最終正確完整的類別資料描述統計表*/
merge %tablenames(1,7,categ_table);
by index;
drop index;
run;
*類別變項統計表輸出;
/*
PROC EXPORT DATA= WORK.categ_table 
            OUTFILE= "D:\研究所\計畫資料\OSA 篩檢計畫\資料分析\20190218OSA age50-80 del mild AHI_15 analysis.xlsx"
            DBMS=EXCEL REPLACE;
     SHEET1="category"; 
RUN;
*/

/*
II. 描述統計表: 連續資料表 (會與上面的類別變項合成一個表)
*/

%macro cont(cpred,i);

/*
STEP 1: Proc means: 得到以下統計值
n mean stddev median min max p25 p75
*/


proc means data=a1 ;
where OSA^=.;
class OSA_suffer;
var &cpred;
output out=means&i n=n mean=mean stddev=stddev median=median min=min max=max p25=p25 p75=p75 ; /*n 被變項名稱蓋掉, 但不會影響最後結果!*/
run;


data vertical&i ; 
set means&i;
medianb=compress(put((round(median,0.01)),5.2))||" ("||compress(put((round(p75-p25,0.01)),5.2))||")";
*minmax="("||compress(put((round(min,0.01)),5.2))||", "||compress(put((round(max,0.01)),5.2))||")";
meansd=compress(put((round(mean,0.01)),5.2))||" ("||compress(put((round(stddev,0.01)),5.2))||")";
*pctl=compress(put((round(p75-p25,0.01)),5.2));
keep OSA_suffer n meansd medianb; 
run;

/*
資料由直的轉成橫的
*/
proc transpose data=vertical&i out=transp_cont&i ;  /*_NAME_  _NAME_是n, mean, median, minmax*/
var n meansd medianb;
run;

data horizontal&i;
set transp_cont&i;
 /* 這個動作先不做 varname=vlabel(&cpred); */
run;

*t test 只能倆倆比較 因此把OSA嚴重度以AHI = 5為分界 轉為OSA有無(更改condition檔案調整分界值);

proc ttest data = a1;
class OSA_suffer;
var &cpred;
ods output equality = equalvar&i(keep = probf)
statistics = stat&i(keep = N mean StdDev)
ttests = ttest&i(keep = method variances probt);
run;

/*
STEP 2: Obtain Appropriate P-value for T-Test
   1. 先做 Equal variance test
   2. 再取 兩種 t test 結果的其中一個 p value
*/

data _null_;
set ttest&i;
if method='集區' then call symput('probt1',probt);
else if method='Satterthwaite' then call symput('probt2',probt);
run;

data pvalue&i;   /*ttest: 最後只要p_final*/
set equalvar&i;


if Probf<  0.05 then do;
pvalue = "&probt2";
end;
else if Probf>=0.05 then pvalue = "&probt1";

length p_final $8.;
 
p_final=round(pvalue,0.001); /*加上本行指令, 要放在最前面, 如果放在後面, 會因為後令蓋前令, 而出現 p=0.003; p=0.000的情況*/ 
                                                /*用以下的宣告方式無效, p_final = put(pvalue, 8.3), 會出現小數點超過3位的結果, 有點奇怪;*/
if 0.001<=pvalue<  0.05 then p_final =('<0.05' ||'*');
if pvalue<0.001 then p_final = ('<0.001' || '**');

keep p_final;  
run;
                                                 
/*
STEP 3: 得到最後檔案
關鍵步驟: statistic, hiv_negative, hiv_positive, 等主要變項, 都在這個步驟宣告
*/
data fin&i (rename=(_name_=statistic col1=all col2=OSA_negative col3=OSA_positive )); 
merge horizontal&i pvalue&i;
run;


/*
宣告&cpred變項的Labeling
*/
data _null_;
set a1;
call symput('name', vlabel(&cpred));
run;

data fina&i;
 set fin&i;
 length varname $30.;
 varname="&name";  /*VARNAME第一次宣告, 原有的宣告方式暫時不用! */  
run;

/*
只要第一個列要有註記 p-value, 變項Labeling即可
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
formats= " ";   /*製造新變項 formats, 把它保持空白, 為的是要與類別資料相呼應*/

keep  varname formats  statistic all OSA_negative OSA_positive index p_final;  
run;
****************************
*													  *
*wilcoxon test and merge			  *
*													  *
****************************;

ODS select WilcoxonTest;
proc npar1way data = a1;
where OSA^=.;
class OSA_suffer;
var &cpred;
ods output WilcoxonTest = Wilcoxon&i
run;

*take nonparametric p_value;
data wil_pvalue&i;
set Wilcoxon&i;
if Name1 = 'P2_WIL'  then select = 1; 
if select ^= 1 then delete;
drop variable name1 label1 nvalue1 select;
run;

data npvalue&i;
set wil_pvalue&i;
length np_final $8.;
np_final=round(cValue1,0.001); /*加上本行指令, 要放在最前面, 如果放在後面, 會因為後令蓋前令, 而出現 p=0.003; p=0.000的情況*/ 
                                                /*用以下的宣告方式無效, p_final = put(pvalue, 8.3), 會出現小數點超過3位的結果, 有點奇怪;*/
if 0.001<=cValue1<  0.05 then np_final =('<0.05' ||'*');
if cValue1<0.001 then np_final = ('<0.001' || '**');
keep np_final;  
run;

data npfin&i (rename=(_name_=statistic col1=all col2=OSA_negative col3=OSA_positive np_final = np_value)); 
merge final_cont&i npvalue&i;
run;

%mend;
%cont(BMI,1) %cont(Waist,2) %cont(Neck,3) %cont(PSQI,4) %cont(C1,5) %cont(C2,6)%cont(C3,7)%cont(C4,8)%cont(C5,9)%cont(C6,10)%cont(C7,11)      
%cont(ESS,12) %cont(TMT1,13) %cont(TMT2,14) %cont(MMSE,15) %cont(MMSE_A,16) %cont(MMSE_B,17) %cont(MMSE_C,18) %cont(MMSE_D,19) %cont(MMSE_E,20) ;
%cont(Allnight_ACT,21)	%cont(Allnight_HR,22)	%cont(Allnight_ln_TP,23)	%cont(Allnight_ln_VL,24)	%cont(Allnight_ln_HF,25)	%cont(Allnight_ln_LF,26)	%cont(Allnight_HF_pct,27)	%cont(Allnight_LF_pct,28)	%cont(Allnight_ln_LF_HF_ratio,29)	
%cont(First_hr_ACT,30)	%cont(First_hr_HR,31)	%cont(First_hr_ln_TP,32)	%cont(First_hr_ln_VL,33)	%cont(First_hr_ln_HF,34)	%cont(First_hr_ln_LF,35)	%cont(First_hr_HF_pct,36)	%cont(First_hr_LF_pct,37)	%cont(First_hr_ln_LF_HF_ratio,38)	
%cont(Second_hr_ACT,39)	%cont(Second_hr_HR,40)	%cont(Second_hr_ln_TP,41)	%cont(Second_hr_ln_VL,42)	%cont(Second_hr_ln_HF,43)	%cont(Second_hr_ln_LF,44)	%cont(Second_hr_HF_pct,45)	%cont(Second_hr_LF_pct,46)	%cont(Second_hr_ln_LF_HF_ratio,47)
%cont(First_two_hr_ACT,48)	%cont(First_two_hr_HR,49)	%cont(First_two_hr_ln_TP,50)	%cont(First_two_hr_ln_VL,51)	%cont(First_two_hr_ln_HF,52)	%cont(First_two_hr_ln_LF,53)	%cont(First_two_hr_HF_pct,54)	%cont(First_two_hr_LF_pct,55)	%cont(First_two_hr_ln_LF_HF_ratio,56)	
%cont(Front_half__ACT,57)	%cont(Front_half__HR,58)	%cont(Front_half__ln_TP,59)	%cont(Front_half__ln_VL,60)	%cont(Front_half__ln_HF,61)	%cont(Front_half__ln_LF,62)	%cont(Front_half__HF_pct,63)	%cont(Front_half__LF_pct,64)	%cont(Front_half__ln_LF_HF_ratio,65)	
%cont(last_half_ACT,66)	%cont(last_half_HR,67)	%cont(last_half_ln_TP,68)	%cont(last_half_ln_VL,69)	%cont(last_half_ln_HF,70)	%cont(last_half_ln_LF,71)	%cont(last_half_HF_pct,72)	%cont(last_half_LF_pct,73)	%cont(last_half_ln_LF_HF_ratio,74)
%cont(Last_two_hr_ACT,75)	%cont(Last_two_hr_HR,76)	%cont(Last_two_hr_ln_TP,77)	%cont(Last_two_hr_ln_VL,78)	%cont(Last_two_hr_ln_HF,79)	%cont(Last_two_hr_ln_LF,80)	%cont(Last_two_hr_HF_pct,81)	%cont(Last_two_hr_LF_pct,82)	%cont(Last_two_hr_ln_LF_HF_ratio,83)
%cont(Second_last_ACT,84)	%cont(Second_last_HR,85)	%cont(Second_last_ln_TP,86)	%cont(Second_last_ln_VL,87)	%cont(Second_last_ln_HF,88)	%cont(Second_last_ln_LF,89)	%cont(Second_last_HF_pct,90)	%cont(Second_last_LF_pct,91)	%cont(Second_last_ln_LF_HF_ratio,92)	
%cont(Last_ACT,93)	%cont(Last_HR,94)	%cont(Last_ln_TP,95)	%cont(Last_ln_VL,96)	%cont(Last_ln_HF,97)	%cont(Last_ln_LF,98)	%cont(Last_HF_pct,99)	%cont(Last_LF_pct,100)	%cont(Last_ln_LF_HF_ratio,101)
%cont(ODI,102) %cont(ODImax,103) %cont(ODE,104) %cont(ODEmax,105) %cont(spo2_baseline,106) %cont(spo2_mean,107) %cont(spo2_lowest,108) %cont(spo2_lowestmean,109)

%macro namesx(j,k,dataname);
%do i=&j %to &k;
&dataname&i
%end;
%mend namesx;
data cont_table;
set %namesx(1,109,npfin);                  /*13個連續變項要改成新檔案的Q個連續*/
drop index;
run;

data cont_table1;
set cont_table;
length stat $15.; /*長度要在這裡宣告!!!*/
stat=statistic;
if statistic='meansd' then stat='Mean (sd)'; 
*if statistic='minmax' then stat='(Min, Max)';
*if statistic='pctl' then stat='(IQR)';
if statistic='medianb' then stat='Median (IQR)';
drop statistic;
run;
data cont_table2;
set cont_table1;
statistic=stat;
drop stat;
run;
*連續變項統計表格輸出;
/*
PROC EXPORT DATA= WORK.cont_table2
            OUTFILE= "D:\研究所\計畫資料\OSA 篩檢計畫\資料分析\20190218OSA age50-80 del mild AHI_15 analysis.xlsx"
            DBMS=EXCEL REPLACE;
     SHEET2="continuous"; 
RUN;
*/

/*最終描述統計表格: */
data cate_cont_table;  	
set categ_table cont_table2;
run;

*類別與連續統計表格合併輸出;

PROC EXPORT DATA= WORK.cate_cont_table
            OUTFILE= "D:\研究所\計畫資料\OSA 篩檢計畫\資料分析\20190527OSA age60-80 del mild AHI_15 col analysis.xlsx"
            DBMS=EXCEL REPLACE;
     SHEET1="mean and med"; 
RUN;


