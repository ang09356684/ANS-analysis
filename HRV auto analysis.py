# -*- coding: utf-8 -*-
"""
Created on Thu Feb 21 14:47:11 2019

@author: kylab
"""
import os
import pandas as pd

import numpy as np
import os
import re
import sys


path="SpO2_Patch_data"
lista=os.listdir(path)
xls = pd.ExcelFile('hrv_list.xlsx')
sheetX = xls.parse('final')
user=sheetX['ID']
PatchID  = sheetX['Patch-No']
Starttime  = sheetX['start']
Endtime= sheetX['end']

startdate=list()
enddate=list()

for i in range(len(Starttime)):
    temp=Starttime[i].split(' ')
    startdate.append(temp[0])
    temp=Endtime[i].split(' ')
    enddate.append(temp[0])


zone_dic={}
for i in range(len(lista)):
    listtemp=os.listdir(path+"/"+ lista[i])
    zone_dic[lista[i]]=listtemp

data_dic={}

for k in range(len(user)):
    
    isbreak=False
    for zone in range(len(zone_dic)):
        for j in range(len(zone_dic[lista[zone]])):
            if user[k] in zone_dic[lista[zone]][j]:
                isbreak=True
                break
        if isbreak:
            break
        
    tempstr=PatchID[k]+'_'+Starttime[k]+'(HRV)'
    
    column = ['data_timestamp','rr','sd','ln(tp)','ln(vl)','ln(lf)','ln(hf)','lf%','hf%','ln(var)','low_high_ratio','wl','temp']
    day = 1
    data1 = {}
    data2 = {}
    data_dir='SpO2_Patch_data/'
    filename=data_dir+lista[zone]+'/'+zone_dic[lista[zone]][j]+'/'+PatchID[k]+'_'+startdate[k]

    path1=[filename+'(ACT).txt',filename+'(HR).txt',filename+'(HRV).txt',filename+'_Ln(HRV).txt']
  #  path1 = openfile_dialog()

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

    if not startdate[k]==enddate[k]:
#day 2
        filename=data_dir+lista[zone]+'/'+zone_dic[lista[zone]][j]+'/'+PatchID[k]+'_'+enddate[k]
        try:
            path2=[filename+'(ACT).txt',filename+'(HR).txt',filename+'(HRV).txt',filename+'_Ln(HRV).txt']
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
    entireframe = entireframe.drop(['Date Time','Angle','Spin ','Variation ','data_timestamp','var','wl_x','wl_y'], axis = 1)
    entireframe = entireframe.rename(columns={'low_high_ratio_x': 'low_high_ratio','low_high_ratio_y':'ln(low_high_ratio)'})

#輸入睡眠時間
    finalframe = entireframe[Starttime[k]: Endtime[k]]

    variable = ['HR','rr','tp','vl','lf','hf','lf%','hf%','low_high_ratio','ln(tp)','ln(vl)','ln(lf)','ln(hf)','ln(var)','ln(low_high_ratio)']

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
              df.loc[delete*-1:,label] = np.nan
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
    mean_dic={}
    
    for key, value in count_mean.items():
        col_dic = {}
        for col1 in value.to_frame().T.columns.values:
            col_dic[col1] = key + '_' + col1

        df = value.to_frame().T.rename(columns=col_dic).T
        dfdic=df.T.to_dict('record')
        mean_dic.update(dfdic[0])

#
    data_dic[user[k]+'_'+enddate[k]]=mean_dic
#    
writer = pd.ExcelWriter('output.xlsx')
##writer = pd.ExcelWriter(Year+'_'+Month+'_'+userID+'_output.xlsx')
pd.DataFrame(data_dic).T.to_excel(writer,'data')
writer.save()

print("Done")
    
    

