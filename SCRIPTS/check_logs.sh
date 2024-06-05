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

DUMMY_VAL='100.00'
#ECMW: ECMWF initialisation data transmission
VAL=`grep 'FATE: ECMWF_DATA_DOWNLOAD = OK' $LOGDIR/${PREV_MONTH_YY}${PREV_MONTH_MM}*.GRIB_RAWRT.download_ecmwf_data.log | uniq | wc -l`
VAL00=$(echo "scale=2; ($VAL/$TOTAL_MONTHLY_RUN)*100" | bc)

#ESO: ftp access ESO – INPUT
#VAL=`grep 'ESO: ESO_SERVER_DOWNLOAD = OK' $LOGDIR/${PREV_MONTH_YY}${PREV_MONTH_MM}*.GRIB_RAWRT.download_ecmwf_data.log | uniq | wc -l`
#VAL01=$(echo "scale=2; (($VAL/2)/$TOTAL_MONTHLY_RUN)*100" | bc)

#ESO: ftp access ESO – OUPUT
#VAL02=$DUMMY_VAL

#FATE: principal network
VAL=`grep 'FATE: FATE_NETWORK_DOWNLOAD = OK' $LOGDIR/${PREV_MONTH_YY}${PREV_MONTH_MM}*.GRIB_RAWRT.download_ecmwf_data.log | wc -l`
VAL03=$(echo "scale=2; (($VAL/2)/$TOTAL_MONTHLY_RUN)*100" | bc)

#ESO: server INPUT
VAL04=$DUMMY_VAL

#ESO: servers OUTPUT
VAL5A=`grep 'ESO server input 1A' $LOGDIR/${PREV_MONTH_YY}${PREV_MONTH_MM}*.GRIB_RAWRT.download_ecmwf_data.log | grep OK | wc -l`
VAL5B=`grep 'ESO server input 1B' $LOGDIR/${PREV_MONTH_YY}${PREV_MONTH_MM}*.GRIB_RAWRT.download_ecmwf_data.log | grep OK | wc -l`
if [ $VAL5A -gt $VAL5B ]; then
  VAL=$VAL5A
else
  VAL=$VAL5B
fi
VAL05=$(echo "scale=2; (($VAL/2)/$TOTAL_MONTHLY_RUN)*100" | bc)

#FATE: model: explosion of simulations
VAL_MNH_FAIL_NIGHT=`grep 'WARNING!!! SIMULATION' $LOGDIR_MNH_NIGHT/${PREV_MONTH_YY}/${PREV_MONTH_YY}${PREV_MONTH_MM}*_schedule.log | wc -l`
VAL_MNH_FAIL_DAY=`grep 'WARNING!!! SIMULATION' $LOGDIR_MNH_DAY/${PREV_MONTH_YY}/${PREV_MONTH_YY}${PREV_MONTH_MM}*_schedule.log | wc -l`
VAL_MNH_FAIL_TOT=$(echo "scale=1; ($VAL_MNH_FAIL_NIGHT+$VAL_MNH_FAIL_DAY)" | bc)
VAL_MNH_FAIL_PERC=$(echo "scale=1; (100-($VAL_MNH_FAIL_TOT/$TOTAL_MONTHLY_RUN)*100)" | bc)
VAL06=$VAL_MNH_FAIL_PERC

#FATE: delay on providing a forecast
VAL07=$DUMMY_VAL

#################################################################
#                     INCREMENTAL MONTH
#################################################################

DUMMY_VAL='100.00'
SUFFIX='GRIB_RAWRT.download_ecmwf_data.log'
VAL08=$DUMMY_VAL; VAL09=$DUMMY_VAL;
VAL10=$DUMMY_VAL; VAL11=$DUMMY_VAL; VAL12=$DUMMY_VAL;
VAL13=$DUMMY_VAL; VAL15=$DUMMY_VAL;
###############################################
# TODO CALCOLARE MEGLIO
TOTAL_MONTHLY_RUN=0
STRINGA_FILES=' ' 
start_date="${STARTOFSERVICE_YYYY}-${STARTOFSERVICE_MM}-01"
end_date=$(date -d "${ENDOFSERVICE_YYYY}-${ENDOFSERVICE_MM}-01 + 1 month" "+%Y-%m-%d")
current_date="$start_date"
while [ "$current_date" != "$end_date" ]; do
    # Formatta la data per mostrare solo mese e anno
    current_month=$(date -d "$current_date" "+%m")
    current_year=$(date -d "$current_date" "+%Y")
    tmp=`ls $LOGDIR_MNH_DAY/${current_year}/${current_year}${current_month}*_schedule.log | wc -l`
    # Aggiungi un mese alla data corrente
    current_date=$(date -d "$current_date + 1 month" "+%Y-%m-%d")
    TOTAL_MONTHLY_RUN=$((TOTAL_MONTHLY_RUN + tmp))
    STRINGA_FILES=$STRINGA_FILES' '$LOGDIR/$current_year$current_month'stoca'$SUFFIX' ' 
done
STRINGA_OK=`echo $STRINGA_FILES | sed -e "s/stoca/\*/g"`

#ECMW: ECMWF initialisation data transmission
VAL=`grep 'FATE: ECMWF_DATA_DOWNLOAD = OK' $STRINGA_OK | uniq | wc -l`
VAL08=$(echo "scale=2; (($VAL/2)/$TOTAL_MONTHLY_RUN)*100" | bc)

#ESO: ftp access ESO – INPUT
#VAL=`grep 'ESO: ESO_SERVER_DOWNLOAD = OK' $STRINGA_OK | uniq | wc -l`
#VAL09=$(echo "scale=2; (($VAL/4)/$TOTAL_MONTHLY_RUN)*100" | bc)

#FATE: principal network
VAL=`grep 'FATE: FATE_NETWORK_DOWNLOAD = OK' $STRINGA_OK | wc -l`
VAL11=$(echo "scale=2; (($VAL/4)/$TOTAL_MONTHLY_RUN)*100" | bc)

#ESO: servers OUTPUT
VAL13A=`grep 'ESO server input 1A' $STRINGA_OK | grep OK | wc -l`
VAL13B=`grep 'ESO server input 1B' $STRINGA_OK | grep OK | wc -l`
if [ $VAL13A -gt $VAL13B ]; then
  VAL=$VAL13A
else
  VAL=$VAL13B
fi
VAL13=$(echo "scale=2; (($VAL/4)/$TOTAL_MONTHLY_RUN)*100" | bc)

#FATE: model: explosion of simulations
#VAL_MNH_FAIL_NIGHT=`grep 'WARNING!!! SIMULATION' $LOGDIR_MNH_NIGHT/${PREV_MONTH_YY}/${PREV_MONTH_YY}*_schedule.log | wc -l`
#VAL_MNH_FAIL_DAY=`grep 'WARNING!!! SIMULATION' $LOGDIR_MNH_DAY/${PREV_MONTH_YY}/${PREV_MONTH_YY}*_schedule.log | wc -l`
VAL_MNH_FAIL_NIGHT=0
VAL_MNH_FAIL_DAY=0
while [ "$current_date" != "$end_date" ]; do
    # Formatta la data per mostrare solo mese e anno
    current_month=$(date -d "$current_date" "+%m")
    current_year=$(date -d "$current_date" "+%Y")
    tmp=`grep 'WARNING!!! SIMULATION' $LOGDIR_MNH_NIGHT/${current_year}/${current_year}${current_month}*_schedule.log | wc -l`
    VAL_MNH_FAIL_NIGHT=$((VAL_MNH_FAIL_NIGHT + tmp))
    tmp=`grep 'WARNING!!! SIMULATION' $LOGDIR_MNH_DAY/${current_year}/${current_year}${current_month}*_schedule.log | wc -l`
    VAL_MNH_FAIL_DAY=$((VAL_MNH_FAIL_DAY + tmp))
    # Aggiungi un mese alla data corrente
    current_date=$(date -d "$current_date + 1 month" "+%Y-%m-%d")
done
VAL_MNH_FAIL_TOT=$(echo "scale=1; ($VAL_MNH_FAIL_NIGHT+$VAL_MNH_FAIL_DAY)" | bc)
VAL_MNH_FAIL_PERC=$(echo "scale=1; (100-($VAL_MNH_FAIL_TOT/$TOTAL_MONTHLY_RUN)*100)" | bc)
VAL14=$VAL_MNH_FAIL_PERC

# CREATE LATEX TABLE
my_caption='FATE: automatic forecasting system performance - statistics'
cat << EOF > $WRKDIR/tableLOGs.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{table}[]
\begin{center}
\begin{tabular}{|l|l|l|l|}
\hline
\multicolumn{1}{|c|}{\cellcolor[HTML]{C0C0C0}\textbf{Automatic}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{Current month}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{Incremental months}} \\\\
\multicolumn{1}{|c|}{\cellcolor[HTML]{C0C0C0}\textbf{forecast system}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{(success rate in \%)}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{(success rate in \%)}} \\\\
\hline
\cellcolor[HTML]{C0C0C0}\textbf{ECMWF:} ECMWF initialisation data transmission  & $VAL00  & $VAL08   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{FATE:} principal network                       & $VAL03  & $VAL11   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{ESO:} server INPUT                             & $VAL04  & $VAL12   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{ESO:} server OUTPUT                            & $VAL05  & $VAL13   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{FATE:} hydrodynamic computation failure         & $VAL06  & $VAL14   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{FATE:} delay on providing a forecast           & $VAL07  & $VAL15   \\\\
\hline
\end{tabular}
\caption{$my_caption}\label{tab:LOGs}
\end{center}
\end{table}
EOF
#\cellcolor[HTML]{C0C0C0}\textbf{FATE:} model: explosion of simulations         & $VAL06  & $VAL14   \\\\
#\cellcolor[HTML]{C0C0C0}\textbf{ESO:} ftp access ESO - INPUT                   & $VAL01  & $VAL09   \\\\
#\cellcolor[HTML]{C0C0C0}\textbf{ESO:} ftp access ESO - OUPUT                   & $VAL02  & $VAL10   \\\\

notice "End of "`basename $0`
exit 0
