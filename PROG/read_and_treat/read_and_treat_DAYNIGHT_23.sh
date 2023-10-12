#!/bin/bash

rm PWV_TREATED_* RH_TREATED_* SEE_TREATED_* TAU_TREATED_* TEMP_TREATED_* WD_TREATED_* WS_TREATED_* -rf
rm *.dat -f

JOB=read_and_treat_AR_exclusive
JOBWD=read_and_treat_AR_exclusive_WD

#EITHER "night" or "day" or both
LISTGG="night day"
hiter="1H" # per compatibilit`'a con quanto si fa per night/day 1

for fcst_lenght in `seq 2 3`
do
for daygg in $LISTGG; do
  GG="${daygg}" 
  OUTPUTDIR=$HOME/DATA/TREATED/`echo ${GG} | cut -c1-3`${fcst_lenght}
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
  
  ls "${FILEPATH}"|grep "AR_${GG}.dat"|cut -d"_" -f1|sort|uniq > lista_auto.asc
  LISTA="lista_auto.asc"
    
  rm *_ARevol_*.dat -f
    
  for datenow in $(cat ${LISTA}); do
    
    YEAR=$(echo $datenow|cut -c1-4)
    MONTH=$(echo $datenow|cut -c5-6)
    DAY=$(echo $datenow|cut -c7-8)
    
    DAYNOW=$(date -u -d "${datenow}" +%Y%m%d)
    DATEB=$(date -u -d"$DAYNOW +1day" +%Y%m%d)
    
    if [ $daygg == "night" ]; then
        VARIABLE="SEE-arcsec"
        rm -f AAATMP
        tail -n+3 "${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_TELEMETRY_output_${GG}.dat" > AAATMP
        sed -e 's/NAN/9999.0/g' -i AAATMP
        rm -f ${JOB}
        ./exe90_debug ${JOB}
    ./${JOB}<<EOF
"${datenow}"
"${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_AR_${GG}.dat"
"${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"SEE_ARevol_${hiter}_${GG}${fcst_lenght}_${datenow}.dat"
EOF
        rm -f ${JOB}

        VARIABLE="TAU-ms"
        rm -f AAATMP
        tail -n+3 "${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_TELEMETRY_output_${GG}.dat" > AAATMP
        sed -e 's/NAN/9999.0/g' -i AAATMP
        rm -f ${JOB}
        ./exe90_debug ${JOB}
    ./${JOB}<<EOF
"${datenow}"
"${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_AR_${GG}.dat"
"${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"TAU_ARevol_${hiter}_${GG}${fcst_lenght}_${datenow}.dat"
EOF
        rm -f ${JOB}

        VARIABLE="GLF-%"
        rm -f AAATMP
        tail -n+3 "${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_TELEMETRY_output_${GG}.dat" > AAATMP
        sed -e 's/NAN/9999.0/g' -i AAATMP
        rm -f ${JOB}
        ./exe90_debug ${JOB}
        ./${JOB}<<EOF
"${datenow}"
"${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_AR_${GG}.dat"
"${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"GLF_ARevol_${hiter}_${GG}${fcst_lenght}_${datenow}.dat"
EOF
        rm -f ${JOB}
    fi

    VARIABLE="PWV-mm"      
    rm -f AAATMP
    tail -n+3 "${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_TELEMETRY_output_${GG}.dat" > AAATMP
    sed -e 's/NAN/9999.0/g' -i AAATMP
    rm -f ${JOB}
    ./exe90_debug ${JOB}
    ./${JOB}<<EOF
"${datenow}"
"${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_AR_${GG}.dat"
"${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"PWV_ARevol_${hiter}_${GG}${fcst_lenght}_${datenow}.dat"
EOF
    rm -f ${JOB}

    VARIABLE="RH-%"
    rm -f AAATMP
    tail -n+3 "${FILEPATH}/${datenow}_rh_k6_evol_time_TELEMETRY_output_${GG}.dat" > AAATMP
    sed -e 's/NAN/9999.0/g' -i AAATMP
    rm -f ${JOB}
    ./exe90_debug ${JOB}
    ./${JOB}<<EOF
"${datenow}"
"${FILEPATH}/${datenow}_rh_k6_evol_time_AR_${GG}.dat"
"${FILEPATH}/${datenow}_rh_k6_evol_time_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"RH_ARevol_${hiter}_${GG}${fcst_lenght}_${datenow}.dat"
EOF
    rm -f ${JOB}
   
    VARIABLE="WS-m/s"
    rm -f AAATMP
    tail -n+3 "${FILEPATH}/${datenow}_wind_k6_evol_time_TELEMETRY_output_${GG}.dat" > AAATMP
    sed -e 's/NAN/9999.0/g' -i AAATMP
    rm -f ${JOB}
    ./exe90_debug ${JOB}
    ./${JOB}<<EOF
"${datenow}"
"${FILEPATH}/${datenow}_wind_k6_evol_time_AR_${GG}.dat"
"${FILEPATH}/${datenow}_wind_k6_evol_time_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"WS_ARevol_${hiter}_${GG}${fcst_lenght}_${datenow}.dat"
EOF
    rm -f ${JOB}
    
    VARIABLE="WD-m/s"
    rm -f AAATMP
    tail -n+3 "${FILEPATH}/${datenow}_winddir_k6_evol_time_TELEMETRY_output_${GG}.dat" > AAATMP
    sed -e 's/NAN/9999.0/g' -i AAATMP
    rm -f ${JOBWD}
    ./exe90_debug ${JOBWD}
    ./${JOBWD}<<EOF
"${datenow}"
"${FILEPATH}/${datenow}_winddir_k6_evol_time_AR_${GG}.dat"
"${FILEPATH}/${datenow}_winddir_k6_evol_time_MNH_${GG}.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"WD_ARevol_${hiter}_${GG}${fcst_lenght}_${datenow}.dat"
EOF
    rm -f ${JOBWD}

    rm -f AAATMP
    
    if [ $GG == "night" ]; then
      test -d "SEE_TREATED"|| mkdir "SEE_TREATED"
      mv SEE_ARevol_${hiter}_${GG}${fcst_lenght}*.dat "SEE_TREATED/"
      test -d "TAU_TREATED"|| mkdir "TAU_TREATED"
      mv TAU_ARevol_${hiter}_${GG}${fcst_lenght}*.dat "TAU_TREATED/"
      test -d "GLF_TREATED"|| mkdir "GLF_TREATED"
      mv GLF_ARevol_${hiter}_${GG}${fcst_lenght}*.dat "GLF_TREATED/"
    fi
    test -d "PWV_TREATED"|| mkdir "PWV_TREATED"
    mv PWV_ARevol_${hiter}_${GG}${fcst_lenght}*.dat "PWV_TREATED/"
    test -d "RH_TREATED"|| mkdir "RH_TREATED"
    mv RH_ARevol_${hiter}_${GG}${fcst_lenght}*.dat "RH_TREATED/"
    test -d "WS_TREATED"|| mkdir "WS_TREATED"
    mv WS_ARevol_${hiter}_${GG}${fcst_lenght}*.dat "WS_TREATED/"
    test -d "WD_TREATED"|| mkdir "WD_TREATED"
    mv WD_ARevol_${hiter}_${GG}${fcst_lenght}*.dat "WD_TREATED/"

  done

done
    if [ $GG == "night" ]; then
      mv "TAU_TREATED" "$OUTPUTDIR/"
      mv "SEE_TREATED" "$OUTPUTDIR/"
      mv "GLF_TREATED" "$OUTPUTDIR/"
    fi
    mv "PWV_TREATED" "$OUTPUTDIR/"
    mv "RH_TREATED" "$OUTPUTDIR/"
    mv "WS_TREATED" "$OUTPUTDIR/"
    mv "WD_TREATED" "$OUTPUTDIR/"

done
