#!/bin/bash

rm PWV_TREATED_* RH_TREATED_* SEE_TREATED_* TAU_TREATED_* TEMP_TREATED_* WD_TREATED_* WS_TREATED_* -rf
rm *.dat -f

JOB=read_and_treat_AR_exclusive
JOBWD=read_and_treat_AR_exclusive_WD

#EITHER "night" or "day" or both
LISTGG="day night"
LISTHH="1H"
fcst_lenght=1
LASTMONTHYEAR=2025
LASTMONTHMONTH=04
LASTMONTHDAY=30
LASTMONTH=${LASTMONTHYEAR}${LASTMONTHMONTH}


for daygg in $LISTGG; do
  GG="${daygg}"
  NEWGG=`echo ${GG} | cut -c1-3`
  OUTPUTDIR=$HOME/DATA/TREATED/$NEWGG${fcst_lenght}
  rm -fr $OUTPUTDIR && mkdir -p $OUTPUTDIR

#################################################################
#Qua ci sono i dati per night1:
#/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/DAT_ARCHIVE/
#che partono dal 19/01/2023

#Qua ci sono quelli per day1:
#/TERASTARMET/FATE_BACKUPS_mesohp2/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/DAT_ARCHIVE/
#Che partono dal 02/02/2023

  if [ $GG = night ]; then
#    if [ $fcst_lenght -eq 1 ]; then
#      FILEPATH='/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/DAT_ARCHIVE'
#    fi
    FILEPATH='/home/report/DATA/DA_TRATTARE/test/night'
  elif [ $GG = day ]; then
#    if [ $fcst_lenght -eq 1 ]; then
#      FILEPATH='/TERASTARMET/FATE_BACKUPS_mesohp2/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/DAT_ARCHIVE'
#    fi
    FILEPATH='/home/report/DATA/DA_TRATTARE/test/day'
  else
    echo "ops some problem"
    exit 1;
  fi
#################################################################

  for hiter in $LISTHH; do
    #START and END of minutes to read consecutively
    if [ $hiter == "1H" ]; then
      MAXMIN=60
      MINMIN=1
    fi
    if [ $hiter == "2H" ]; then
      MAXMIN=120
      MINMIN=61
    fi
    if [ $hiter == "3H" ]; then
      MAXMIN=180
      MINMIN=121
    fi
    if [ $hiter == "4H" ]; then
      MAXMIN=240
      MINMIN=181
    fi
    if [ $hiter == "5H" ]; then
      MAXMIN=300
      MINMIN=241
    fi
    if [ $hiter == "6H" ]; then
      MAXMIN=360
      MINMIN=301
    fi

    LISTATMP="lista_buffer5_auto_TMP.asc"
    LISTA="lista_buffer5_auto.asc"
  
    ls "${FILEPATH}"|grep "AR_${GG}.dat"|cut -d"_" -f1|sort|uniq > ${LISTATMP}

    rm *_ARevol_*.dat -f
    
    for datenow in $(cat ${LISTATMP}); do
    
      YEAR=$(echo $datenow|cut -c1-4)
      MONTH=$(echo $datenow|cut -c5-6)
      DAY=$(echo $datenow|cut -c7-8)
    
      DAYNOW=$(date -u -d "${datenow}" +%Y%m%d)
      DATEB=$(date -u -d"$DAYNOW +1day" +%Y%m%d)
    

      if [ $daygg == "night" ]; then
          if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_AR_${GG}.dat"|wc -l) -eq 1 ]; then
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
          fi

          if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_AR_${GG}.dat"|wc -l) -eq 1 ]; then
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
          fi

          if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_AR_${GG}.dat"|wc -l) -eq 1 ]; then
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
      fi

      if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_AR_${GG}.dat"|wc -l ) -eq 1 ]; then
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
      fi

      if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_rh_k6_evol_time_AR_${GG}.dat"|wc -l) -eq 1 ]; then
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
      fi
   
      if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_wind_k6_evol_time_AR_${GG}.dat"|wc -l) -eq 1 ]; then
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
      fi

      if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_winddir_k6_evol_time_AR_${GG}.dat"|wc -l) -eq 1 ]; then
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
      fi

      rm -f AAATMP

    done

    rm ${LISTATMP} -f

# List
    if [ $daygg == "night" ]; then
        LISTA="$OUTPUTDIR/list_SEE.txt"
        ls SEE_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
        LISTA="$OUTPUTDIR/list_TAU.txt"
        ls TAU_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
        LISTA="$OUTPUTDIR/list_GLF.txt"
        ls GLF_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
    fi
    LISTA="$OUTPUTDIR/list_PWV.txt"
    ls PWV_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
    LISTA="$OUTPUTDIR/list_RH.txt"
    ls RH_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
    LISTA="$OUTPUTDIR/list_WS.txt"
    ls WS_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
    LISTA="$OUTPUTDIR/list_WD.txt"
    ls WD_ARevol_${hiter}_${NEWGG}$fcst_lenght*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}

    if [ $daygg == "night" ]; then
        LISTA="$OUTPUTDIR/list_SEE_LastMonth.txt"
        ls SEE_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
        LISTA="$OUTPUTDIR/list_TAU_LastMonth.txt"
        ls TAU_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
        LISTA="$OUTPUTDIR/list_GLF_LastMonth.txt"
        ls GLF_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
    fi
    LISTA="$OUTPUTDIR/list_PWV_LastMonth.txt"
    ls PWV_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
    LISTA="$OUTPUTDIR/list_RH_LastMonth.txt"
    ls RH_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
    LISTA="$OUTPUTDIR/list_WS_LastMonth.txt"
    ls WS_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}
    LISTA="$OUTPUTDIR/list_WD_LastMonth.txt"
    ls WD_ARevol_${hiter}_${NEWGG}${fcst_lenght}_${LASTMONTH}*.dat |cut -d"_" -f5|cut -d"." -f1|sort|uniq > ${LISTA}

#
    if [ $daygg == "night" ]; then
        test -d "SEE_TREATED"|| mkdir "SEE_TREATED"
        mv SEE_ARevol_${hiter}_${NEWGG}*.dat "SEE_TREATED/"
        test -d "TAU_TREATED"|| mkdir "TAU_TREATED"
        mv TAU_ARevol_${hiter}_${NEWGG}*.dat "TAU_TREATED/"
        test -d "GLF_TREATED"|| mkdir "GLF_TREATED"
        mv GLF_ARevol_${hiter}_${NEWGG}*.dat "GLF_TREATED/"
    fi
    test -d "PWV_TREATED"|| mkdir "PWV_TREATED"
    mv PWV_ARevol_${hiter}_${NEWGG}*.dat "PWV_TREATED/"
    test -d "RH_TREATED"|| mkdir "RH_TREATED"
    mv RH_ARevol_${hiter}_${NEWGG}*.dat "RH_TREATED/"
    test -d "WS_TREATED"|| mkdir "WS_TREATED"
    mv WS_ARevol_${hiter}_${NEWGG}*.dat "WS_TREATED/"
    test -d "WD_TREATED"|| mkdir "WD_TREATED"
    mv WD_ARevol_${hiter}_${NEWGG}*.dat "WD_TREATED/"

    if [ $daygg == "night" ]; then
        mv "TAU_TREATED" "$OUTPUTDIR/"
        mv "SEE_TREATED" "$OUTPUTDIR/"
        mv "GLF_TREATED" "$OUTPUTDIR/"
    fi
    mv "PWV_TREATED" "$OUTPUTDIR/"
    mv "RH_TREATED" "$OUTPUTDIR/"
    mv "WS_TREATED" "$OUTPUTDIR/"
    mv "WD_TREATED" "$OUTPUTDIR/"

  done
done

# Exit
exit 0;

