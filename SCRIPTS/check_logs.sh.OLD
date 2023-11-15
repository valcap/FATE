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
# START OF STEP 2
# Use the outputs of the program by Elena to compile the latex file
notice "Start of "`basename $0`

#################################################################
# HOUSEKEEPING

#################################################################
#                     CURRENT MONTH
#################################################################
PREV_MONTH_MM=`date +%m --date "today - 1 month"`
CURR_MONTH_MM=`date +%m`
PREV_MONTH_YY=`date +%Y --date "today - 1 month"`
DAYS_PREV_MON=`date +%d --date "${PREV_MONTH_YY}-${CURR_MONTH_MM}-01 -1 day"`
TOTAL_MONTHLY_RUN=$(($DAYS_PREV_MON*2))

#ECMW: ECMWF initialisation data transmission
VAL0=$NODATA_STR

#ESO: ftp access ESO – INPUT
VAL1=`grep 'ECMWF_FILES_GRIB_RAWRT' $LOGDIR/${PREV_MONTH_YY}${PREV_MONTH_MM}*.GRIB_RAWRT.check_upload_to_eso.log | grep SUCCESSFULL | wc -l`
VAL1_PERC=$(echo "scale=2; ($VAL1/$TOTAL_MONTHLY_RUN)*100" | bc)

#ESO: ftp access ESO – OUPUT
VAL2=$NODATA_STR

#FATE: principal network
VAL3=$NODATA_STR

#ESO: server INPUT
VAL4=$NODATA_STR

#ESO: servers OUTPUT
VAL5A=`grep 'CONNECTION_TO_ESO_SERVER_2A' $LOGDIR/${PREV_MONTH_YY}${PREV_MONTH_MM}*.GRIB_RAWRT.check_upload_to_eso.log | grep SUCCESSFULL | wc -l`
VAL5B=`grep 'CONNECTION_TO_ESO_SERVER_2B' $LOGDIR/${PREV_MONTH_YY}${PREV_MONTH_MM}*.GRIB_RAWRT.check_upload_to_eso.log | grep SUCCESSFULL | wc -l`
if [ $VAL5A -gt $VAL5B ]; then
  VAL5=$VAL5A
else
  VAL5=$VAL5B
fi
VAL5_PERC=$(echo "scale=2; ($VAL5/$TOTAL_MONTHLY_RUN)*100" | bc)

#FATE: model: explosion of simulations
VAL6=`grep 'MNH_OUTPUTS_ON_SHARE_DIR' $LOGDIR/${PREV_MONTH_YY}${PREV_MONTH_MM}*.GRIB_RAWRT.check_upload_to_eso.log | grep SUCCESSFULL | wc -l`
VAL6_PERC=$(echo "scale=2; 100-($VAL6/$TOTAL_MONTHLY_RUN)*100" | bc)

#ESO: retrieving real-time observations
VAL7=$NODATA_STR

#FATE: delay on providing a forecast
VAL8=$NODATA_STR

#################################################################
#                     INCREMENTAL MONTH
#################################################################
#ECMW: ECMWF initialisation data transmission
VAL9=$NODATA_STR

#ESO: ftp access ESO – INPUT
VAL10=`grep 'ECMWF_FILES_GRIB_RAWRT' $LOGDIR/${PREV_MONTH_YY}*.GRIB_RAWRT.check_upload_to_eso.log | grep SUCCESSFULL | wc -l`
VAL10_PERC=$(echo "scale=2; ($VAL10/$TOTAL_MONTHLY_RUN)*100" | bc)

#ESO: ftp access ESO – OUPUT
VAL11=$NODATA_STR

#FATE: principal network
VAL12=$NODATA_STR

#ESO: server INPUT
VAL13=$NODATA_STR

#ESO: servers OUTPUT
VAL14A=`grep 'CONNECTION_TO_ESO_SERVER_2A' $LOGDIR/${PREV_MONTH_YY}*.GRIB_RAWRT.check_upload_to_eso.log | grep SUCCESSFULL | wc -l`
VAL14B=`grep 'CONNECTION_TO_ESO_SERVER_2B' $LOGDIR/${PREV_MONTH_YY}*.GRIB_RAWRT.check_upload_to_eso.log | grep SUCCESSFULL | wc -l`
if [ $VAL14A -gt $VAL14B ]; then
  VAL14=$VAL14A
else
  VAL14=$VAL14B
fi
VAL14_PERC=$(echo "scale=2; ($VAL14/$TOTAL_MONTHLY_RUN)*100" | bc)

#FATE: model: explosion of simulations
VAL15=`grep 'MNH_OUTPUTS_ON_SHARE_DIR' $LOGDIR/${PREV_MONTH_YY}*.GRIB_RAWRT.check_upload_to_eso.log | grep SUCCESSFULL | wc -l`
VAL15_PERC=$(echo "scale=2; 100-($VAL15/$TOTAL_MONTHLY_RUN)*100" | bc)

#ESO: retrieving real-time observations
VAL16=$NODATA_STR

#FATE: delay on providing a forecast
VAL17=$NODATA_STR


my_caption='LOG FILES OUTPUTS'
cat << EOF > $WRKDIR/tableLOGs.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{table}[]
\begin{center}
\begin{tabular}{|l|l|l|l|}
\hline
\multicolumn{1}{|c|}{\cellcolor[HTML]{C0C0C0}\textbf{Automatic}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{Current month}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{Incremental months}} \\\\
\multicolumn{1}{|c|}{\cellcolor[HTML]{C0C0C0}\textbf{forecast system}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{(success rate in perc)}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{(success rate in perc)}} \\\\
\hline
\cellcolor[HTML]{C0C0C0}\textbf{ECMW:} ECMWF initialisation data transmission  & $VAL0           & $VAL9    \\\\
\cellcolor[HTML]{C0C0C0}\textbf{ESO:} ftp access ESO - INPUT                   & $VAL1           & $VAL10   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{ESO:} ftp access ESO - OUPUT                   & $VAL2           & $VAL11   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{FATE:} principal network                       & $VAL3           & $VAL12   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{ESO:} server INPUT                             & $VAL4           & $VAL13   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{ESO:} server OUTPUT                            & $VAL5           & $VAL14   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{FATE:} model: explosion of simulations         & $VAL6           & $VAL15   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{ESO:} retrieving real-time observations        & $VAL7           & $VAL16   \\\\
\cellcolor[HTML]{C0C0C0}\textbf{FATE:} delay on providing a forecast           & $VAL8           & $VAL17   \\\\
\hline
\end{tabular}
\caption{$my_caption}
\end{center}
\end{table}
EOF

notice "End of "`basename $0`
exit 0

