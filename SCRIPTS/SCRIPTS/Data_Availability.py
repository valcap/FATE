#!python3

import sys,os,glob,getopt
import datetime as dt
import numpy as np
import pandas as pd
import ephem

o=ephem.Observer()
o.lat='-24:37:37.358'
o.long='-70:24:14.249'
o.elevation=2635
#The following takes into account the average refraction index of the athmosphere
o.horizon = '-0:34'
s=ephem.Sun()
s.compute()

#CSV PATH NIGHT
DATAPATH_NIGHT="/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/csv_PAR/"

#CSV PATH DAY
DATAPATH_DAY="/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/csv_PAR/"

def validate_date(date_text):
    try:
        dateout=dt.datetime.strptime(date_text, '%Y%m%d')
        return dateout
    except ValueError:
        raise ValueError("Incorrect data format, should be %Y%m%d-%H%M%S")
        print("ERROR: Incorrect data format, should be YYYYMMDD")
        sys.exit(1)

def readESOcsv(csvfile):
    #Read the ESO csv file and return two numpy arrays, UTDATE, OUTDATA and valid flag, with UT dates and the extracted data
#    print('reading ESO data from file=',csvfile)
    try:
        csvDATAFRAME=pd.read_csv(csvfile,header=None,names=['DATA'],index_col=0,skiprows=2,parse_dates=True, comment='#',sep=',')
    except:
        print('ERROR READING FILE ',csvfile)
        sys.exit(1)
    return csvDATAFRAME

def readESOcsv_pwv_A(csvfile):
    #Read the ESO csv file and return two numpy arrays, UTDATE, OUTDATA and valid flag, with UT dates and the extracted data
    # THIS ROUTINE READS THE PWV AND SELECT ONLY PLATFORM A
#    print('reading ESO data from file=',csvfile)
    try:
        csvDATAFRAME=pd.read_csv(csvfile,header=None,names=['PLATFORM','DATA'],index_col=1,skiprows=2,parse_dates=True, comment='#',sep=',')
    except:
        print('ERROR READING FILE ',csvfile)
        sys.exit(1)
    csvDATAFRAME=csvDATAFRAME[csvDATAFRAME['PLATFORM']=="A"]
    return csvDATAFRAME

argv = sys.argv[1:]
try:
    opts, args = getopt.getopt(argv,"hs:e:t:o:",["startdate=","enddate=","type=","outfile="])
except:
    print('ERROR PARSING COMMAND LINE OPTIONS, TRY DataAvailability.py -h')
    print(opts)
    print(args)
    sys.exit(1)
if len(opts) != 3:
    print('WRONG COMMAND LINE OPTIONS, TRY DataAvailability.py -h')
for opt, arg in opts:
    if opt == '-h':
        print('DataAvailability.py -s <startdate YYYYMMDD> -e <enddate YYYYMMDD> -t <either night or day> -o <outfile.csv>')
        sys.exit()
    elif opt in ("-s", "--startdate"):
        startdate = str(arg)
        startdate=validate_date(startdate)
    elif opt in ("-e", "--enddate"):
        enddate = str(arg)
        enddate=validate_date(enddate)
    elif opt in ("-t", "--type"):
        typerun = str(arg)
        if ((typerun != 'night') and (typerun != 'day')):
            print('ERROR: TYPE MUST BE EITHER night OR day')
            sys.exit(1)
    elif opt in ("-o", "--outfile"):
        outfile = str(arg)
        if os.path.isfile(outfile):
            print('ERROR: file '+outfile+' ALREADY EXISTS')
            sys.exit(1)
    else:
        print('WRONG COMMAND LINE OPTION, TRY DataAvailability.py -h')

if typerun == 'day' :
    DATAPATH=DATAPATH_DAY
else:
    DATAPATH=DATAPATH_NIGHT

print("RUN TYPE = ",typerun)
print("START DATE = ",startdate)
print("END DATE = ",enddate)
print(DATAPATH)

DATELIST=pd.date_range(startdate,enddate,freq='d')
print(DATELIST)


if typerun == 'night' :
    SeeNans=0
    SeeTot=0
    TauNans=0
    TauTot=0
    GlfNans=0
    GlfTot=0
PwvNans=0
PwvTot=0
RhNans=0
RhTot=0
WsNans=0
WsTot=0
WdNans=0
WdTot=0

for dateitem in DATELIST :
    print('### - date=',dateitem)
    dateitemnext=dateitem+dt.timedelta(days=1)
    yearstring=str(dateitem.year)
    monthstring=str(dateitem.month)
    daystring=str(dateitem.day)
    yearstringnext=str(dateitemnext.year)
    monthstringnext=str(dateitemnext.month)
    daystringnext=str(dateitemnext.day)

    if typerun == 'day' :
        #From sunrise to sunset
        o.date=yearstring+'/'+monthstring+'/'+daystring
        ENDperiod=o.next_setting(s).datetime()
        o.date=yearstring+'/'+monthstring+'/'+daystring
        STARTperiod=o.next_rising(s).datetime()
    else:
        #From sunset to sunrise
        o.date=yearstring+'/'+monthstring+'/'+daystring
        STARTperiod=o.next_setting(s).datetime()
        o.date=yearstringnext+'/'+monthstringnext+'/'+daystringnext
        ENDperiod=o.next_rising(s).datetime()
    print('      start=',STARTperiod,'        end=',ENDperiod)
    print(dateitem.strftime('%Y%m%d'))

    strtime=dateitem.strftime('%Y%m%d')
    if typerun == 'night' :
        TmpDf=readESOcsv(DATAPATH+strtime+'_see_wdbeso.csv')
        TmpDf=TmpDf.loc[STARTperiod:ENDperiod]
        if len(TmpDf) > 0:
            TmpDf=TmpDf.resample('5min').mean()
            SeeNans=SeeNans+TmpDf['DATA'].isna().sum()
            SeeTot=SeeTot+int((ENDperiod-STARTperiod).total_seconds()/60/5)
        else:
            Tmflen=int((ENDperiod-STARTperiod).total_seconds()/60/5)
            SeeNans=SeeNans+Tmflen
            SeeTot=SeeTot+Tmflen
        
        TmpDf=readESOcsv(DATAPATH+strtime+'_tau_wdbeso.csv')
        TmpDf=TmpDf.loc[STARTperiod:ENDperiod]
        if len(TmpDf) > 0:
            TmpDf=TmpDf.resample('5min').mean()
            TauNans=TauNans+TmpDf['DATA'].isna().sum()
            TauTot=TauTot+int((ENDperiod-STARTperiod).total_seconds()/60/5)
        else:
            Tmflen=int((ENDperiod-STARTperiod).total_seconds()/60/5)
            TauNans=TauNans+Tmflen
            TauTot=TauTot+Tmflen
        
        TmpDf=readESOcsv(DATAPATH+strtime+'_glf_wdbeso.csv')
        TmpDf=TmpDf.loc[STARTperiod:ENDperiod]
        if len(TmpDf) > 0:
            TmpDf=TmpDf.resample('5min').mean()
            GlfNans=GlfNans+TmpDf['DATA'].isna().sum()
            GlfTot=GlfTot+int((ENDperiod-STARTperiod).total_seconds()/60/5)
        else:
            Tmflen=int((ENDperiod-STARTperiod).total_seconds()/60/5)
            GlfNans=GlfNans+Tmflen
            GlfTot=GlfTot+Tmflen
    
    TmpDf=readESOcsv_pwv_A(DATAPATH+strtime+'_pwv_wdbeso.csv')
    TmpDf=TmpDf.loc[STARTperiod:ENDperiod]
    if len(TmpDf) > 0:
        TmpDf=TmpDf.resample('5min').mean()
        PwvNans=PwvNans+TmpDf['DATA'].isna().sum()
        PwvTot=PwvTot+int((ENDperiod-STARTperiod).total_seconds()/60/5)
    else:
        Tmflen=int((ENDperiod-STARTperiod).total_seconds()/60/5)
        PwvNans=PwvNans+Tmflen
        PwvTot=PwvTot+Tmflen
    
    TmpDf=readESOcsv(DATAPATH+strtime+'_rh_wdbeso.csv')
    TmpDf=TmpDf.loc[STARTperiod:ENDperiod]
    if len(TmpDf) > 0:
        TmpDf=TmpDf.resample('5min').mean()
        RhNans=RhNans+TmpDf['DATA'].isna().sum()
        RhTot=RhTot+int((ENDperiod-STARTperiod).total_seconds()/60/5)
    else:
        Tmflen=int((ENDperiod-STARTperiod).total_seconds()/60/5)
        RhNans=RhNans+Tmflen
        RhTot=RhTot+Tmflen

    TmpDf=readESOcsv(DATAPATH+strtime+'_ws_wdbeso.csv')
    TmpDf=TmpDf.loc[STARTperiod:ENDperiod]
    if len(TmpDf) > 0:
        TmpDf=TmpDf.resample('5min').mean()
        WsNans=WsNans+TmpDf['DATA'].isna().sum()
        WsTot=WsTot+int((ENDperiod-STARTperiod).total_seconds()/60/5)
    else:
        Tmflen=int((ENDperiod-STARTperiod).total_seconds()/60/5)
        WsNans=WsNans+Tmflen
        WsTot=WsTot+Tmflen

    TmpDf=readESOcsv(DATAPATH+strtime+'_wd_wdbeso.csv')
    TmpDf=TmpDf.loc[STARTperiod:ENDperiod]
    if len(TmpDf) > 0:
        TmpDf=TmpDf.resample('5min').mean()
        WdNans=WdNans+TmpDf['DATA'].isna().sum()
        WdTot=WdTot+int((ENDperiod-STARTperiod).total_seconds()/60/5)
    else:
        Tmflen=int((ENDperiod-STARTperiod).total_seconds()/60/5)
        WdNans=WdNans+Tmflen
        WdTot=WdTot+Tmflen

print("###################################")
print("##############SUMMARY##############")


if typerun == 'night' :
    print('See percentage = ',100-SeeNans/SeeTot*100,'%')
    print('Tau percentage = ',100-TauNans/TauTot*100,'%')
    print('Glf percentage = ',100-GlfNans/GlfTot*100,'%')
print('Pwv percentage = ',100-PwvNans/PwvTot*100,'%')
print('Rh percentage = ',100-RhNans/RhTot*100,'%')
print('Ws percentage = ',100-WsNans/WsTot*100,'%')
print('Wd percentage = ',100-WdNans/WdTot*100,'%')

if typerun == 'night' :
    OutDict={'Missing': [SeeNans,TauNans,GlfNans,PwvNans,RhNans,WsNans,WdNans], 'Expected': pd.Series([SeeTot,TauTot,GlfTot,PwvTot,RhTot,WsTot,WdTot], index=['See','Tau','Glf','Pwv','Rh','Ws','Wd'])}
else:
    OutDict={'Missing': [PwvNans,RhNans,WsNans,WdNans], 'Expected': pd.Series([PwvTot,RhTot,WsTot,WdTot], index=['Pwv','Rh','Ws','Wd'])}

OutCsv=pd.DataFrame(data=OutDict)
OutCsv.to_csv(outfile,index=True,index_label='variable')
print('Written file ',outfile)
