#!/bin/bash

############################################################################
# Usage
############################################################################
if [ $# -ne 1 ]; then
  echo 'Not enough/too many arguments'
  echo "Usage: $0 env_file"
  echo "Example: $0 $HOME/SCRIPTS/fate-report.env"
  echo ""
  exit 1
else
  envfile=$1
fi

# Source of env file
if [ -e $envfile ]; then
  source $envfile
else 
  echo "ops $envfile does not exist in "`pwd`; exit 1
fi

# Source of functions
if [ -e $funcfile ]; then
  source $funcfile
else
  echo "ops $funcfile does not exist in "`pwd`; exit 1
fi

#################################################################
notice "Start of "`basename $0`

#################################################################
#                     CURRENT MONTH
#################################################################
PREV_MONTH_MM=`date +%m --date "today - 1 month"`
CURR_MONTH_MM=`date +%m --date "today"`
PREV_MONTH_YY=`date +%Y --date "today - 1 month"`
CURR_MONTH_YY=`date +%Y --date "today"`
DAYS_PREV_MON=`date +%d --date "${CURR_MONTH_YY}-${CURR_MONTH_MM}-01 -1 day"`
TOTAL_MONTHLY_RUN=$(($DAYS_PREV_MON*2))

# NIGHT Observations received
rm -f $WRKDIR/pippo.night
python3 Data_Availability.py -s ${PREV_MONTH_YY}${PREV_MONTH_MM}01 -e ${PREV_MONTH_YY}${PREV_MONTH_MM}${DAYS_PREV_MON} -t night -o $WRKDIR/pippo.night >& /dev/null
#echo python3 Data_Availability.py -s ${PREV_MONTH_YY}${PREV_MONTH_MM}01 -e ${PREV_MONTH_YY}${PREV_MONTH_MM}${DAYS_PREV_MON} -t night -o $WRKDIR/pippo.night

# ASTRO
VAL_SEE_MISS_NIGHT=`cat $WRKDIR/pippo.night | grep 'See' | cut -d ',' -f2`
VAL_SEE_EXPE_NIGHT=`cat $WRKDIR/pippo.night | grep 'See' | cut -d ',' -f3`
VAL_SEE_FAIL_PERC=$(echo "scale=3; (100-($VAL_SEE_MISS_NIGHT/$VAL_SEE_EXPE_NIGHT)*100)" | bc)
VAL_TAU_MISS_NIGHT=`cat $WRKDIR/pippo.night | grep 'Tau' | cut -d ',' -f2`
VAL_TAU_EXPE_NIGHT=`cat $WRKDIR/pippo.night | grep 'Tau' | cut -d ',' -f3`
VAL_TAU_FAIL_PERC=$(echo "scale=3; (100-($VAL_TAU_MISS_NIGHT/$VAL_TAU_EXPE_NIGHT)*100)" | bc)
VAL_GLF_MISS_NIGHT=`cat $WRKDIR/pippo.night | grep 'Glf' | cut -d ',' -f2`
VAL_GLF_EXPE_NIGHT=`cat $WRKDIR/pippo.night | grep 'Glf' | cut -d ',' -f3`
VAL_GLF_FAIL_PERC=$(echo "scale=3; (100-($VAL_GLF_MISS_NIGHT/$VAL_GLF_EXPE_NIGHT)*100)" | bc)
VAL00=$VAL_SEE_FAIL_PERC
VAL01=$VAL_TAU_FAIL_PERC
VAL02=$VAL_GLF_FAIL_PERC
# METEO WS
AAA=`cat $WRKDIR/pippo.night | grep 'Ws' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.night | grep 'Ws' | cut -d ',' -f3`
DDD=0
VAL_WS_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_WS_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_WS_FAIL_PERC=$(echo "scale=3; (100-($VAL_WS_MISS_TOT/$VAL_WS_EXPE_TOT)*100)" | bc)
VAL03=$VAL_WS_FAIL_PERC
# METEO WD
AAA=`cat $WRKDIR/pippo.night | grep 'Wd' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.night | grep 'Wd' | cut -d ',' -f3`
DDD=0
VAL_WD_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_WD_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_WD_FAIL_PERC=$(echo "scale=3; (100-($VAL_WD_MISS_TOT/$VAL_WD_EXPE_TOT)*100)" | bc)
VAL04=$VAL_WD_FAIL_PERC
# METEO RH
AAA=`cat $WRKDIR/pippo.night | grep 'Rh' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.night | grep 'Rh' | cut -d ',' -f3`
DDD=0
VAL_RH_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_RH_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_RH_FAIL_PERC=$(echo "scale=3; (100-($VAL_RH_MISS_TOT/$VAL_RH_EXPE_TOT)*100)" | bc)
VAL05=$VAL_RH_FAIL_PERC
# METEO PWV
AAA=`cat $WRKDIR/pippo.night | grep 'Pwv' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.night | grep 'Pwv' | cut -d ',' -f3`
DDD=0
VAL_PWV_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_PWV_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_PWV_FAIL_PERC=$(echo "scale=3; (100-($VAL_PWV_MISS_TOT/$VAL_PWV_EXPE_TOT)*100)" | bc)
VAL06=$VAL_PWV_FAIL_PERC

# DAY Observations received
rm -f $WRKDIR/pippo.day
python3 Data_Availability.py -s ${PREV_MONTH_YY}${PREV_MONTH_MM}01 -e ${PREV_MONTH_YY}${PREV_MONTH_MM}${DAYS_PREV_MON} -t day -o $WRKDIR/pippo.day >& /dev/null
#echo python3 Data_Availability.py -s ${PREV_MONTH_YY}${PREV_MONTH_MM}01 -e ${PREV_MONTH_YY}${PREV_MONTH_MM}${DAYS_PREV_MON} -t day -o $WRKDIR/pippo.day 

# METEO WS
AAA=`cat $WRKDIR/pippo.day | grep 'Ws' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.day | grep 'Ws' | cut -d ',' -f3`
DDD=0
VAL_WS_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_WS_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_WS_FAIL_PERC=$(echo "scale=3; (100-($VAL_WS_MISS_TOT/$VAL_WS_EXPE_TOT)*100)" | bc)
VAL14=$VAL_WS_FAIL_PERC
# METEO WD
AAA=`cat $WRKDIR/pippo.day | grep 'Wd' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.day | grep 'Wd' | cut -d ',' -f3`
DDD=0
VAL_WD_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_WD_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_WD_FAIL_PERC=$(echo "scale=3; (100-($VAL_WD_MISS_TOT/$VAL_WD_EXPE_TOT)*100)" | bc)
VAL15=$VAL_WD_FAIL_PERC
# METEO RH
AAA=`cat $WRKDIR/pippo.day | grep 'Rh' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.day | grep 'Rh' | cut -d ',' -f3`
DDD=0
VAL_RH_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_RH_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_RH_FAIL_PERC=$(echo "scale=3; (100-($VAL_RH_MISS_TOT/$VAL_RH_EXPE_TOT)*100)" | bc)
VAL16=$VAL_RH_FAIL_PERC
# METEO PWV
AAA=`cat $WRKDIR/pippo.day | grep 'Pwv' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.day | grep 'Pwv' | cut -d ',' -f3`
DDD=0
VAL_PWV_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_PWV_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_PWV_FAIL_PERC=$(echo "scale=3; (100-($VAL_PWV_MISS_TOT/$VAL_PWV_EXPE_TOT)*100)" | bc)
VAL17=$VAL_PWV_FAIL_PERC

rm -f $WRKDIR/pippo.night $WRKDIR/pippo.day

#################################################################
#                     INCREMENTAL MONTH
#################################################################
PREV_MONTH_MM=`date +%m --date "today - 1 month"`
CURR_MONTH_MM=`date +%m --date "today"`
PREV_MONTH_YY=`date +%Y --date "today - 1 month"`
CURR_MONTH_YY=`date +%Y --date "today"`
DAYS_PREV_MON=`date +%d --date "${CURR_MONTH_YY}-${CURR_MONTH_MM}-01 -1 day"`
# Converte le date in timestamp
timestamp1=$(converti_in_timestamp "$STARTOFSERVICE_YYYY-$STARTOFSERVICE_MM-$STARTOFSERVICE_DD")
timestamp2=$(converti_in_timestamp "${PREV_MONTH_YY}-${PREV_MONTH_MM}-${DAYS_PREV_MON}")
# Calcola la differenza in giorni
differenza=$(differenza_in_giorni $timestamp1 $timestamp2)
TOTAL_MONTHLY_RUN=$(($differenza*2))

# NIGHT Observations received
rm -f $WRKDIR/pippo.night
python3 Data_Availability.py -s $STARTOFSERVICE_STR2 -e ${PREV_MONTH_YY}${PREV_MONTH_MM}${DAYS_PREV_MON} -t night -o $WRKDIR/pippo.night >& /dev/null
#echo python3 Data_Availability.py -s $STARTOFSERVICE_STR2 -e ${PREV_MONTH_YY}${PREV_MONTH_MM}${DAYS_PREV_MON} -t night -o $WRKDIR/pippo.night 

# ASTRO
VAL_SEE_MISS_NIGHT=`cat $WRKDIR/pippo.night | grep 'See' | cut -d ',' -f2`
VAL_SEE_EXPE_NIGHT=`cat $WRKDIR/pippo.night | grep 'See' | cut -d ',' -f3`
VAL_SEE_FAIL_PERC=$(echo "scale=3; (100-($VAL_SEE_MISS_NIGHT/$VAL_SEE_EXPE_NIGHT)*100)" | bc)
VAL_TAU_MISS_NIGHT=`cat $WRKDIR/pippo.night | grep 'Tau' | cut -d ',' -f2`
VAL_TAU_EXPE_NIGHT=`cat $WRKDIR/pippo.night | grep 'Tau' | cut -d ',' -f3`
VAL_TAU_FAIL_PERC=$(echo "scale=3; (100-($VAL_TAU_MISS_NIGHT/$VAL_TAU_EXPE_NIGHT)*100)" | bc)
VAL_GLF_MISS_NIGHT=`cat $WRKDIR/pippo.night | grep 'Glf' | cut -d ',' -f2`
VAL_GLF_EXPE_NIGHT=`cat $WRKDIR/pippo.night | grep 'Glf' | cut -d ',' -f3`
VAL_GLF_FAIL_PERC=$(echo "scale=3; (100-($VAL_GLF_MISS_NIGHT/$VAL_GLF_EXPE_NIGHT)*100)" | bc)
VAL07=$VAL_SEE_FAIL_PERC; VAL08=$VAL_TAU_FAIL_PERC; VAL09=$VAL_GLF_FAIL_PERC
# METEO WS
AAA=`cat $WRKDIR/pippo.night | grep 'Ws' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.night | grep 'Ws' | cut -d ',' -f3`
DDD=0
VAL_WS_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_WS_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_WS_FAIL_PERC=$(echo "scale=3; (100-($VAL_WS_MISS_TOT/$VAL_WS_EXPE_TOT)*100)" | bc)
VAL10=$VAL_WS_FAIL_PERC
# METEO WD
AAA=`cat $WRKDIR/pippo.night | grep 'Wd' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.night | grep 'Wd' | cut -d ',' -f3`
DDD=0
VAL_WD_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_WD_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_WD_FAIL_PERC=$(echo "scale=3; (100-($VAL_WD_MISS_TOT/$VAL_WD_EXPE_TOT)*100)" | bc)
VAL11=$VAL_WD_FAIL_PERC
# METEO RH
AAA=`cat $WRKDIR/pippo.night | grep 'Rh' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.night | grep 'Rh' | cut -d ',' -f3`
DDD=0
VAL_RH_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_RH_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_RH_FAIL_PERC=$(echo "scale=3; (100-($VAL_RH_MISS_TOT/$VAL_RH_EXPE_TOT)*100)" | bc)
VAL12=$VAL_RH_FAIL_PERC
# METEO PWV
AAA=`cat $WRKDIR/pippo.night | grep 'Pwv' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.night | grep 'Pwv' | cut -d ',' -f3`
DDD=0
VAL_PWV_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_PWV_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_PWV_FAIL_PERC=$(echo "scale=3; (100-($VAL_PWV_MISS_TOT/$VAL_PWV_EXPE_TOT)*100)" | bc)
VAL13=$VAL_PWV_FAIL_PERC

# DAY Observations received
rm -f $WRKDIR/pippo.day
python3 Data_Availability.py -s $STARTOFSERVICE_STR2 -e ${PREV_MONTH_YY}${PREV_MONTH_MM}${DAYS_PREV_MON} -t day -o $WRKDIR/pippo.day >& /dev/null
#echo python3 Data_Availability.py -s $STARTOFSERVICE_STR2 -e ${PREV_MONTH_YY}${PREV_MONTH_MM}${DAYS_PREV_MON} -t day -o $WRKDIR/pippo.day

# METEO WS
AAA=`cat $WRKDIR/pippo.day | grep 'Ws' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.day | grep 'Ws' | cut -d ',' -f3`
DDD=0
VAL_WS_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_WS_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_WS_FAIL_PERC=$(echo "scale=3; (100-($VAL_WS_MISS_TOT/$VAL_WS_EXPE_TOT)*100)" | bc)
VAL18=$VAL_WS_FAIL_PERC
# METEO WD
AAA=`cat $WRKDIR/pippo.day | grep 'Wd' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.day | grep 'Wd' | cut -d ',' -f3`
DDD=0
VAL_WD_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_WD_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_WD_FAIL_PERC=$(echo "scale=3; (100-($VAL_WD_MISS_TOT/$VAL_WD_EXPE_TOT)*100)" | bc)
VAL19=$VAL_WD_FAIL_PERC
# METEO RH
AAA=`cat $WRKDIR/pippo.day | grep 'Rh' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.day | grep 'Rh' | cut -d ',' -f3`
DDD=0
VAL_RH_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_RH_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_RH_FAIL_PERC=$(echo "scale=3; (100-($VAL_RH_MISS_TOT/$VAL_RH_EXPE_TOT)*100)" | bc)
VAL20=$VAL_RH_FAIL_PERC
# METEO PWV
AAA=`cat $WRKDIR/pippo.day | grep 'Pwv' | cut -d ',' -f2`
BBB=0
CCC=`cat $WRKDIR/pippo.day | grep 'Pwv' | cut -d ',' -f3`
DDD=0
VAL_PWV_MISS_TOT=$(echo "scale=0; ($AAA+$BBB)" | bc)
VAL_PWV_EXPE_TOT=$(echo "scale=0; ($CCC+$DDD)" | bc)
VAL_PWV_FAIL_PERC=$(echo "scale=3; (100-($VAL_PWV_MISS_TOT/$VAL_PWV_EXPE_TOT)*100)" | bc)
VAL21=$VAL_PWV_FAIL_PERC

rm -f $WRKDIR/pippo.night $WRKDIR/pippo.day

my_caption='night1 - real-time observations availability'
cat << EOF > $WRKDIR/tableLOGs_ObsNight.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{table}[]
\begin{center}
\begin{tabular}{|l|l|l|}
\hline
\rowcolor[HTML]{C0C0C0} 
\textbf{TODO} & \textbf{Current month} & \textbf{Incremental months}\\\\
\rowcolor[HTML]{C0C0C0} 
              & \textbf{(success rate \%)} & \textbf{(success rate \%)}\\\\
\hline
SEE                & $VAL00 & $VAL07 \\\\
TAU                & $VAL01 & $VAL08 \\\\
GLF                & $VAL02 & $VAL09 \\\\
WS                 & $VAL03 & $VAL10 \\\\
WD                 & $VAL04 & $VAL11 \\\\
RH                 & $VAL05 & $VAL12 \\\\
PWV                & $VAL06 & $VAL13 \\\\  
\hline
\end{tabular}
\caption{$my_caption}
\end{center}
\end{table}
EOF

my_caption='day1 - real-time observations availability'
cat << EOF > $WRKDIR/tableLOGs_ObsDay.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{table}[]
\begin{center}
\begin{tabular}{|l|l|l|}
\hline
\rowcolor[HTML]{C0C0C0} 
\textbf{TODO} & \textbf{Current month} & \textbf{Incremental months}\\\\
\rowcolor[HTML]{C0C0C0} 
              & \textbf{(success rate \%)} & \textbf{(success rate \%)}\\\\
\hline
WS                 & $VAL14 & $VAL18 \\\\
WD                 & $VAL15 & $VAL19 \\\\
RH                 & $VAL16 & $VAL20 \\\\
PWV                & $VAL17 & $VAL21 \\\\
\hline  
\end{tabular}
\caption{$my_caption}
\end{center}
\end{table}
EOF

notice "End of "`basename $0`
exit 0
