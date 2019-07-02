# -*- coding: utf-8 -*-
# %%
import pandas as pd
import numpy as np
import os
import re
import sys
import matplotlib.pyplot as plt
import matplotlib.dates as mdate
from datetime import timedelta
#%matplotlib inline
#pd.options.display.max_columns

def openfile_dialog():
    from PyQt5 import QtGui, QtWidgets
    app = QtWidgets.QApplication([dir])
    fname = QtWidgets.QFileDialog.getOpenFileNames(None, "選擇要分析的txt檔案", '.', filter="txt (*.txt )")
    
    if (not fname[0]):
        QtWidgets.QMessageBox.critical(None,'錯誤','未選擇要分析的txt檔案')
        return ''
    return fname[0]

column = ['data_timestamp','rr','sd','ln(tp)','ln(vl)','ln(lf)','ln(hf)','lf%','hf%','ln(var)','low_high_ratio','wl','temp']
day = 1
data1 = {}
data2 = {}
try:
    path1 = openfile_dialog()
    if (len(path1) != 4):
        raise ValueError
    for i in path1:
        filename = os.path.basename(i)
        if 'HRV' not in filename:
            key = re.search(r'\(.+\)',filename).group(0)[1:-1] + '1'
            data1[key] = pd.read_table(open(i, 'r'),sep = ';')
        else:
            if 'Ln(HRV)' not in filename:
                key = re.search(r'\(.+\)',filename).group(0)[1:-1] + '1'
                data1[key] = pd.read_table(open(i, 'r'),sep = ';')
            else:
                key ='Ln' + re.search(r'\(.+\)',filename).group(0)[1:-1] + '1'
                data1[key] = pd.read_table(open(i, 'r'),sep = ';',names=column,skiprows=[0]).drop(['rr','sd','lf%','hf%'],axis = 1)
except:
    print("ERROR")
    sys.exit(0)


#day 2
try:
    path2 = openfile_dialog()
    if (len(path2) != 4): 
        raise ValueError
    for i in path2:
        filename = os.path.basename(i)
        if 'HRV' not in filename:
            key = re.search(r'\(.+\)',filename).group(0)[1:-1] + '2'
            data2[key] = pd.read_table(open(i, 'r'),sep = ';')
        else:
            if 'Ln(HRV)' not in filename:
                key = re.search(r'\(.+\)',filename).group(0)[1:-1] + '2'
                data2[key] = pd.read_table(open(i, 'r'),sep = ';')
            else:
                key ='Ln' + re.search(r'\(.+\)',filename).group(0)[1:-1] + '2'
                data2[key] = pd.read_table(open(i, 'r'),sep = ';',names=column,skiprows=[0]).drop(['rr','sd','lf%','hf%'],axis = 1)
    day = 2
except:
    print("only one day data")
    
#1day merge
if day == 1:
    ACT = data1['ACT1']
    HR = data1['HR1']
    preHRV = data1['HRV1']
    preHRVLn = data1['LnHRV1']
    
    if ACT['Date Time'][0] > ACT.loc[len(data1['ACT1'])-1,'Date Time']:
        ACT = ACT.sort_values(['Date Time'],ascending=True).reset_index(drop = True)
    
#2day merge
else:
    ACT1 = data1['ACT1']
    ACT2 = data2['ACT2']
    
    if ACT1['Date Time'][0] > ACT1.loc[len(data1['ACT1'])-1,'Date Time']:
        ACT1 = ACT1.sort_values(['Date Time'],ascending=True).reset_index(drop = True)
        ACT2 = ACT2.sort_values(['Date Time'],ascending=True).reset_index(drop = True)
        
    ACT = ACT1.append(ACT2)    
    HR = data1['HR1'].append(data2['HR2'])
    preHRV1 = data1['HRV1']
    preHRV2 = data2['HRV2']
    firstlen= len(preHRV1['data_timestamp']) #456
    secondlen = len(preHRV2['data_timestamp']) #302

    preHRV = preHRV1.append(preHRV2)

    dateone = data1['ACT1']['Date Time'][0].split(' ')[0]
    datetwo = data2['ACT2']['Date Time'][0].split(' ')[0]
    
    preHRV = preHRV.reset_index(drop=True)
    preHRV.loc[:firstlen,'temp'] = dateone
    preHRV.loc[firstlen:,'temp'] = datetwo
    
    preHRVLn = data1['LnHRV1'].append(data2['LnHRV2']).drop(['temp'], axis = 1)

    
AH = pd.merge(ACT, HR, left_on = 'Date Time', right_on = 'Date Time', how = 'left')
AH['Date Time'] = pd.to_datetime(AH['Date Time'])

HRV = pd.merge(preHRV, preHRVLn, on ='data_timestamp', how = 'left')

if day ==1:
    HRV['temp'] = data1['ACT1']['Date Time'][0].split(' ')[0]
    HRV['data_timestamp'] = pd.to_datetime(HRV['temp'].str.cat(HRV['data_timestamp'], sep = ' '))
    HRV = HRV.drop(['temp'], axis = 1)
else:
    HRV['data_timestamp'] = pd.to_datetime(HRV['temp'].str.cat(HRV['data_timestamp'], sep = ' '))
    HRV = HRV.drop(['temp'], axis = 1)
    
period = (AH['Date Time'][len(AH['Date Time'])-1] - AH['Date Time'][0]).total_seconds() + 1

standertime = pd.DataFrame(pd.date_range( AH['Date Time'][0], periods = period, freq = '1s'))
standertime.columns = ['standertime']

preframe = pd.merge(standertime, AH, left_on = 'standertime',right_on = 'Date Time', how = 'outer')
entireframe = pd.merge(preframe, HRV, left_on = 'standertime', right_on = 'data_timestamp', how = 'outer')
#將txt中的INF(文字)被轉成numpy的inf 換置成numpy的NaN
#entireframe = entireframe.replace([np.inf, -np.inf], np.nan) 

entireframe = entireframe.set_index(entireframe['standertime'],drop=True) 
del entireframe['standertime']
entireframe.index = pd.to_datetime(entireframe.index, format = '%Y-%m-%d %H:%M:%S')
entireframe = entireframe.drop(['Angle','Spin ','Variation ','data_timestamp','var','wl_x','wl_y'], axis = 1)
entireframe = entireframe.rename(columns={'low_high_ratio_x': 'low_high_ratio','low_high_ratio_y':'ln(low_high_ratio)'})

# %%
#自動抓取第二天中午時間
seconddaynoon = pd.to_datetime(data1['ACT1']['Date Time'][0].split(' ')[0]) + timedelta(days = 1.5)

#選取睡眠時間
sleeptime = entireframe[['HR','ACT']]
sleeptime = sleeptime[sleeptime.index < seconddaynoon]


sleeptime = sleeptime.dropna(axis = 'rows')
sleeptime = sleeptime[sleeptime['ACT']<=200] 

ax = sleeptime.plot(x_compat=True, figsize = (15,8))

ax.xaxis.set_major_formatter(mdate.DateFormatter('%Y-%m-%d %H:%M:%S'))
plt.xticks(pd.date_range(sleeptime.index[0],sleeptime.index[-1],freq='1h'),fontsize = '12', rotation=90)
plt.show()
#'min', 'h'
#D:\研究所\計畫資料\OSA 篩檢計畫\SpO2 Patch data\三芝社區

# %%
#輸入睡眠時間
finalframe = entireframe['2019-04-11 22:00:00': '2019-04-12 08:00:00']

variable = ['HR','rr','tp','vl','lf','hf','lf%','hf%','low_high_ratio','ln(tp)','ln(vl)','ln(lf)','ln(hf)','ln(var)','ln(low_high_ratio)']

#計算SD>100比率和排除SD>100
def countMean(df):
          checkError = pd.DataFrame(df['sd'].dropna())
          if len(checkError) == 0:
              error = 1
          else:
              error = len(checkError.loc[checkError['sd'] > 100])/len(checkError)
           
          df = df[df['sd'] < 100]   
          df = df.dropna(axis = 'rows')
          datapoint = len(df[df['ACT'] <= 10])
                 
          if 0.4 < len(df)*0.05 <= 0.5: #round(0.5)會變成 0
              delete = 1
          else:
              delete = int(round(len(df)*0.05, 0))#前後5%的資料不納入計算
              
          df.insert(0,'error',error)
          df.insert(1,'datapoint',datapoint)
                 
          for label in variable:
              df = df.sort_values([label],ascending = True)
              df.loc[0:delete,label] = np.nan
              df.loc[delete*-1:,label] = np.nan #用*-1避免 -0造成的整排nan
              df = df.replace([np.inf, -np.inf], np.nan) 
          return df[df['ACT'] <= 10].mean()

def split_list(a_list):
    half = len(a_list)//2
    return a_list[:half], a_list[half:]

#若是奇數後半部會多一格
fronthalf, lasthalf = split_list(finalframe)

count_mean = {}
count_mean['allnight'] = countMean(finalframe)
count_mean['firsthr'] = countMean(finalframe[0:3600])
count_mean['secondhr'] = countMean(finalframe[3601:7200])
count_mean['firsttwohr'] = countMean(finalframe[0:7200])
count_mean['fronthalf'] = countMean(fronthalf)
count_mean['lasthalf'] = countMean(lasthalf)
count_mean['lasttwohr'] = countMean(finalframe[-7201:-1])
count_mean['secondlast'] = countMean(finalframe[-7201:-3601])
count_mean['last'] = countMean(finalframe[-3601:-1])

mean_df = pd.DataFrame()

for key, value in count_mean.items():
    col_dic = {}
    for j in value.to_frame().T.columns.values:
        col_dic[j] = key + '_' + j

    df = value.to_frame().T.rename(columns=col_dic).T
    mean_df = mean_df.append(df)

mean_df = mean_df.T

mean_df.to_excel(r'D:\研究所\計畫資料\OSA 篩檢計畫\2.xlsx')