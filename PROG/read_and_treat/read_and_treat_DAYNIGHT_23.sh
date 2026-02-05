#!/bin/bash

if [ $# -ne 2 ]; then
  echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  echo "------------- need exactly two input variable ----------------"
  echo "------------- sh $0 night|day 2|3             ----------------"
  echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  exit 8
fi
LISTGG=$1
fcst_lenght=$2
# Check if LISTGG is either "night" or "day"
if [ "$LISTGG" != "night" ] && [ "$LISTGG" != "day" ]; then
  echo "Error: LISTGG must be either 'night' or 'day'."
  exit 1
fi
# Check if fcst_lenght is either "2" or "3"
if [ "$fcst_lenght" != "2" ] && [ "$fcst_lenght" != "3" ]; then
  echo "Error: fcst_lenght must be either '2' or '3'."
  exit 1
fi
#echo ------------------------
echo LISTGG $LISTGG
echo fcst_lenght $fcst_lenght
echo ------------------------
#exit

rm PWV_TREATED_* RH_TREATED_* SEE_TREATED_* TAU_TREATED_* TEMP_TREATED_* WD_TREATED_* WS_TREATED_* -rf
rm *.dat -f

JOB=read_and_treat_AR_exclusive
JOBWD=read_and_treat_AR_exclusive_WD

#############
#EITHER "night" or "day"
#LISTGG="day"
#EITHER "2" or "3"
#fcst_lenght=3
#############
hiter="1H" # per compatibilit`'a con quanto si fa per night/day 1
# TODO TODO TODO
# cambiare ogni mese
#LASTMONTHYEAR=$(date -d "last month" +%Y)
#LASTMONTHMONTH=$(date -d "last month" +%m)
#LASTMONTHDAY=$(date -d "$(date +%Y-%m-01) -1 day" +%d)
LASTMONTHYEAR=2026
LASTMONTHMONTH=01
LASTMONTHDAY=31
LASTMONTH=${LASTMONTHYEAR}${LASTMONTHMONTH}

####################
# Start of procedure
####################
for daygg in $LISTGG; do
  GG="${daygg}" 
  NEWGG=`echo ${GG} | cut -c1-3`
  OUTPUTDIR=$HOME/DATA/TREATED/$NEWGG${fcst_lenght}
  rm -fr $OUTPUTDIR && mkdir -p $OUTPUTDIR
  echo "working on fcst_lenght $fcst_lenght daygg $daygg"
#################################################################
#Qua ci sono i dati per night1:
#/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/DAT_ARCHIVE/
#che partono dal 19/01/2023

#Qua ci sono i dati per night2:
#/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION_night2/postproc/DAT_ARCHIVE/
#che partono dal 10/09/2023

#Qua ci sono quelli per night3:
#/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION_night3/postproc/DAT_ARCHIVE/
#Che partono dal 09/09/2023

#Qua ci sono quelli per day1:
#/TERASTARMET/FATE_BACKUPS_mesohp2/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/DAT_ARCHIVE/
#Che partono dal 02/02/2023

#Qua ci sono quelli per day2:
#/TERASTARMET/FATE_BACKUPS_mesohp2/AUTOMATION_OUTPUTS/AUTOREGRESSION_day2/postproc/DAT_ARCHIVE/
#Che partono dal 08/09/2023

#Qua ci sono quelli per day3:
#/TERASTARMET/FATE_BACKUPS_mesohp2/AUTOMATION_OUTPUTS/AUTOREGRESSION_day3/postproc/DAT_ARCHIVE/
#Che partono dal 09/09/2023
  
  if [ $GG = night ]; then
    if [ $fcst_lenght -eq 2 ]; then
      FILEPATH='/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION_night2/postproc/DAT_ARCHIVE'
    fi
    if [ $fcst_lenght -eq 3 ]; then
      FILEPATH='/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION_night3/postproc/DAT_ARCHIVE'
    fi
  elif [ $GG = day ]; then
    if [ $fcst_lenght -eq 2 ]; then
      FILEPATH='/TERASTARMET/FATE_BACKUPS_mesohp2/AUTOMATION_OUTPUTS/AUTOREGRESSION_day2/postproc/DAT_ARCHIVE'
    fi
    if [ $fcst_lenght -eq 3 ]; then
      FILEPATH='/TERASTARMET/FATE_BACKUPS_mesohp2/AUTOMATION_OUTPUTS/AUTOREGRESSION_day3/postproc/DAT_ARCHIVE'
    fi
  else
    echo "ops some problem"
    exit 1;
  fi
#################################################################

  MAXMIN=60
  MINMIN=1
  
  LISTATMP="lista_auto.temp"
  ls "${FILEPATH}"|grep "AR_${GG}.dat"|cut -d"_" -f1|sort|uniq > $LISTATMP
  LISTA="lista_auto.asc"; rm -f $LISTA
  for datenow in $(cat ${LISTATMP}); do
##########################################################################
    # TODO: MIGLIORARE
    # MODIFICA 1 GIUGNO 2024 DATA DI INIZIO DEL SERVIZIO
    if [ $datenow -lt 20240601 ]; then
      echo "skipping $datenow"
      continue
    fi
##########################################################################
    if [ $datenow -le $LASTMONTHYEAR$LASTMONTHMONTH$LASTMONTHDAY ]; then
      echo $datenow >> $LISTA
    fi
  done
  rm -f $LISTATMP
    
  rm *_ARevol_*.dat -f
    
  for datenow in $(cat ${LISTA}); do
    
    YEAR=$(echo $datenow|cut -c1-4)
    MONTH=$(echo $datenow|cut -c5-6)
    DAY=$(echo $datenow|cut -c7-8)
    echo "+++ working on $GG --- $YEAR-$MONTH-$DAY +++"
    
    DAYNOW=$(date -u -d "${datenow}" +%Y%m%d)
    DATEB=$(date -u -d"$DAYNOW +1day" +%Y%m%d)
    
    if [ $daygg == "night" ]; then
        VARIABLE="SEE-arcsec"
        rm -f AAATMP
        tail -n+3 "${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_TELEMETRY_output_${GG}.dat" > AAATMP
        sed -e 's/NAN/9999.0/g' -i AAATMP
        rm -f ${JOB}
        ./exe90_debug ${JOB} 
    ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_AR_${GG}.dat"
"${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"SEE_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${datenow}.dat"
EOF
        rm -f ${JOB}

        VARIABLE="TAU-ms"
        rm -f AAATMP
        tail -n+3 "${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_TELEMETRY_output_${GG}.dat" > AAATMP
        sed -e 's/NAN/9999.0/g' -i AAATMP
        rm -f ${JOB}
        ./exe90_debug ${JOB}
    ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_AR_${GG}.dat"
"${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"TAU_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${datenow}.dat"
EOF
        rm -f ${JOB}

        VARIABLE="GLF-%"
        rm -f AAATMP
        tail -n+3 "${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_TELEMETRY_output_${GG}.dat" > AAATMP
        sed -e 's/NAN/9999.0/g' -i AAATMP
        rm -f ${JOB}
        ./exe90_debug ${JOB} 
        ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_AR_${GG}.dat"
"${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"GLF_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${datenow}.dat"
EOF
        rm -f ${JOB}
    fi

    VARIABLE="PWV-mm"      
    rm -f AAATMP
    tail -n+3 "${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_TELEMETRY_output_${GG}.dat" > AAATMP
    sed -e 's/NAN/9999.0/g' -i AAATMP
    rm -f ${JOB}
    ./exe90_debug ${JOB} 
    ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_AR_${GG}.dat"
"${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"PWV_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${datenow}.dat"
EOF
    rm -f ${JOB}

    VARIABLE="RH-%"
    rm -f AAATMP
    tail -n+3 "${FILEPATH}/${datenow}_rh_k6_evol_time_TELEMETRY_output_${GG}.dat" > AAATMP
    sed -e 's/NAN/9999.0/g' -i AAATMP
    rm -f ${JOB}
    ./exe90_debug ${JOB} 
    ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_rh_k6_evol_time_AR_${GG}.dat"
"${FILEPATH}/${datenow}_rh_k6_evol_time_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"RH_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${datenow}.dat"
EOF
    rm -f ${JOB}
   
    VARIABLE="WS-m/s"
    rm -f AAATMP
    tail -n+3 "${FILEPATH}/${datenow}_wind_k6_evol_time_TELEMETRY_output_${GG}.dat" > AAATMP
    sed -e 's/NAN/9999.0/g' -i AAATMP
    rm -f ${JOB}
    ./exe90_debug ${JOB}
    ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_wind_k6_evol_time_AR_${GG}.dat"
"${FILEPATH}/${datenow}_wind_k6_evol_time_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"WS_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${datenow}.dat"
EOF
    rm -f ${JOB}
    
    VARIABLE="WD-m/s"
    rm -f AAATMP
    tail -n+3 "${FILEPATH}/${datenow}_winddir_k6_evol_time_TELEMETRY_output_${GG}.dat" > AAATMP
    sed -e 's/NAN/9999.0/g' -i AAATMP
    rm -f ${JOBWD}
    ./exe90_debug ${JOBWD} 
    ./${JOBWD}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_winddir_k6_evol_time_AR_${GG}.dat"
"${FILEPATH}/${datenow}_winddir_k6_evol_time_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"WD_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${datenow}.dat"
EOF
    rm -f ${JOBWD}

    rm -f AAATMP

    if [ $GG == "night" ]; then
      test -d "SEE_TREATED"|| mkdir "SEE_TREATED"
      mv -f SEE_ARevol_${hiter}_${NEWGG}${fcst_lenght}*.dat "SEE_TREATED/"
      test -d "TAU_TREATED"|| mkdir "TAU_TREATED"
      mv -f TAU_ARevol_${hiter}_${NEWGG}${fcst_lenght}*.dat "TAU_TREATED/"
      test -d "GLF_TREATED"|| mkdir "GLF_TREATED"
      mv -f GLF_ARevol_${hiter}_${NEWGG}${fcst_lenght}*.dat "GLF_TREATED/"
    fi
    test -d "PWV_TREATED"|| mkdir "PWV_TREATED"
    mv -f PWV_ARevol_${hiter}_${NEWGG}${fcst_lenght}*.dat "PWV_TREATED/"
    test -d "RH_TREATED"|| mkdir "RH_TREATED"
    mv -f RH_ARevol_${hiter}_${NEWGG}${fcst_lenght}*.dat "RH_TREATED/"
    test -d "WS_TREATED"|| mkdir "WS_TREATED"
    mv -f WS_ARevol_${hiter}_${NEWGG}${fcst_lenght}*.dat "WS_TREATED/"
    test -d "WD_TREATED"|| mkdir "WD_TREATED"
    mv -f WD_ARevol_${hiter}_${NEWGG}${fcst_lenght}*.dat "WD_TREATED/"

  done

done


# List
if [ $daygg == "night" ]; then
        LISTA="$OUTPUTDIR/list_SEE.txt"
        ls SEE_TREATED/SEE_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
        LISTA="$OUTPUTDIR/list_TAU.txt"
        ls TAU_TREATED/TAU_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
        LISTA="$OUTPUTDIR/list_GLF.txt"
        ls GLF_TREATED/GLF_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
fi
LISTA="$OUTPUTDIR/list_PWV.txt"
ls PWV_TREATED/PWV_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
LISTA="$OUTPUTDIR/list_RH.txt"
ls RH_TREATED/RH_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
LISTA="$OUTPUTDIR/list_WS.txt"
ls WS_TREATED/WS_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
LISTA="$OUTPUTDIR/list_WD.txt"
ls WD_TREATED/WD_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}

if [ $daygg == "night" ]; then
        LISTA="$OUTPUTDIR/list_SEE_LastMonth.txt"
        ls SEE_TREATED/SEE_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
        LISTA="$OUTPUTDIR/list_TAU_LastMonth.txt"
        ls TAU_TREATED/TAU_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
        LISTA="$OUTPUTDIR/list_GLF_LastMonth.txt"
        ls GLF_TREATED/GLF_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
fi
LISTA="$OUTPUTDIR/list_PWV_LastMonth.txt"
ls PWV_TREATED/PWV_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
LISTA="$OUTPUTDIR/list_RH_LastMonth.txt"
ls RH_TREATED/RH_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
LISTA="$OUTPUTDIR/list_WS_LastMonth.txt"
ls WS_TREATED/WS_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
LISTA="$OUTPUTDIR/list_WD_LastMonth.txt"
ls WD_TREATED/WD_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f6|cut -d"." -f1|sort|uniq > ${LISTA}
    
if [ $GG == "night" ]; then
      mv -fv "TAU_TREATED" "$OUTPUTDIR/"
      mv -fv "SEE_TREATED" "$OUTPUTDIR/"
      mv -fv "GLF_TREATED" "$OUTPUTDIR/"
fi
mv -fv "PWV_TREATED" "$OUTPUTDIR/"
mv -fv "RH_TREATED" "$OUTPUTDIR/"
mv -fv "WS_TREATED" "$OUTPUTDIR/"
mv -fv "WD_TREATED" "$OUTPUTDIR/"

exit 0;

