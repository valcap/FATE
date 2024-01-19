#!/bin/bash

rm PWV_TREATED_* RH_TREATED_* SEE_TREATED_* TAU_TREATED_* TEMP_TREATED_* WD_TREATED_* WS_TREATED_* -rf
rm *.dat -f

JOB=read_and_treat_AR_exclusive
JOBWD=read_and_treat_AR_exclusive_WD

#EITHER "night" or "day"
LISTGG="night day"
LISTHH="1H"

for daygg in $LISTGG; do
  GG="${daygg}"

# Create || destroy OUTPUTDIR
  OUTPUTDIR=$HOME/DATA/TREATED/`echo ${GG} | cut -c1-3`'_PERSIST'
  rm -fr $OUTPUTDIR && mkdir -p $OUTPUTDIR
#  OUTPUTDIR="${GG}_PERSIST"
#  if [ ! -d $OUTPUTDIR ]; then
#    mkdir -p $OUTPUTDIR
#  else
#    rm -fr $OUTPUTDIR
#  fi

  if [ $GG = night ]; then
#   FILEPATH='/TERASTARMET/FATE_BACKUPS_mesohp1/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/DAT_ARCHIVE'
    FILEPATH='/home/report/DATA/DA_TRATTARE/test/night'
  elif [ $GG = day ]; then
#   FILEPATH='/TERASTARMET/FATE_BACKUPS_mesohp2/AUTOMATION_OUTPUTS/AUTOREGRESSION/postproc/DAT_ARCHIVE'
    FILEPATH='/home/report/DATA/DA_TRATTARE/test/day'
  else
    echo "ops some problem"
    exit 1;
  fi

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

    LISTATMP="lista_auto.asc"
    LISTA="lista_auto.asc"
  
    ls "${FILEPATH}"|grep "AR_${GG}_PERSIST.dat"|cut -d"_" -f1|sort|uniq > ${LISTATMP}

    rm *_PERSIST_*.dat -f
    
    for datenow in $(cat ${LISTATMP}); do
    
      YEAR=$(echo $datenow|cut -c1-4)
      MONTH=$(echo $datenow|cut -c5-6)
      DAY=$(echo $datenow|cut -c7-8)
    
      DAYNOW=$(date -u -d "${datenow}" +%Y%m%d)
      DATEB=$(date -u -d"$DAYNOW +1day" +%Y%m%d)
    

      if [ $daygg == "night" ]; then
          VARIABLE="SEE-arcsec"
          rm -f AAATMP
          tail -n+3 "${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_TELEMETRY_output_${GG}_PERSIST.dat" > AAATMP
          sed -e 's/NAN/9999.0/g' -i AAATMP
          rm -f ${JOB}
          ./exe90_debug ${JOB}
          ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_AR_${GG}_PERSIST.dat"
"${FILEPATH}/${datenow}_see_evol_time_Height_5_20000_MNH_${GG}_PERSIST.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"SEE_PERSIST_${datenow}.dat"
EOF
          rm -f ${JOB}
          
          VARIABLE="TAU-ms"
          rm -f AAATMP
          tail -n+3 "${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_TELEMETRY_output_${GG}_PERSIST.dat" > AAATMP
          sed -e 's/NAN/9999.0/g' -i AAATMP
          rm -f ${JOB}
          ./exe90_debug ${JOB}
          ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_AR_${GG}_PERSIST.dat"
"${FILEPATH}/${datenow}_tau_evol_time_Height_5_20000_MNH_${GG}_PERSIST.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"TAU_PERSIST_${datenow}.dat"
EOF
          rm -f ${JOB}

          VARIABLE="GLF-%"
          rm -f AAATMP
          tail -n+3 "${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_TELEMETRY_output_${GG}_PERSIST.dat" > AAATMP
          sed -e 's/NAN/9999.0/g' -i AAATMP
          rm -f ${JOB}
          ./exe90_debug ${JOB}
          ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_AR_${GG}_PERSIST.dat"
"${FILEPATH}/${datenow}_glf_evol_time_Height_5_20000_MNH_${GG}_PERSIST.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"GLF_PERSIST_${datenow}.dat"
EOF
          rm -f ${JOB}
      fi

      if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_AR_${GG}.dat"|wc -l ) -eq 1 ]; then
          VARIABLE="PWV-mm"
          rm -f AAATMP
          tail -n+3 "${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_TELEMETRY_output_${GG}_PERSIST.dat" > AAATMP
          sed -e 's/NAN/9999.0/g' -i AAATMP
          rm -f ${JOB}
          ./exe90_debug ${JOB}
          ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_AR_${GG}_PERSIST.dat"
"${FILEPATH}/${datenow}_wapor_evol_time_Height_5_20000_MNH_${GG}_PERSIST.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"PWV_PERSIST_${datenow}.dat"
EOF
          rm -f ${JOB}
      fi

      if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_rh_k6_evol_time_AR_${GG}.dat"|wc -l) -eq 1 ]; then
          VARIABLE="RH-%"
          rm -f AAATMP
          tail -n+3 "${FILEPATH}/${datenow}_rh_k6_evol_time_TELEMETRY_output_${GG}_PERSIST.dat" > AAATMP
          sed -e 's/NAN/9999.0/g' -i AAATMP
          rm -f ${JOB}
          ./exe90_debug ${JOB}
          ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_rh_k6_evol_time_AR_${GG}_PERSIST.dat"
"${FILEPATH}/${datenow}_rh_k6_evol_time_MNH_${GG}_PERSIST.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"RH_PERSIST_${datenow}.dat"
EOF
          rm -f ${JOB}
      fi
   
      if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_wind_k6_evol_time_AR_${GG}.dat"|wc -l) -eq 1 ]; then
          VARIABLE="WS-m/s"
          rm -f AAATMP
          tail -n+3 "${FILEPATH}/${datenow}_wind_k6_evol_time_TELEMETRY_output_${GG}_PERSIST.dat" > AAATMP
          sed -e 's/NAN/9999.0/g' -i AAATMP
          rm -f ${JOB}
          ./exe90_debug ${JOB}
          ./${JOB}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_wind_k6_evol_time_AR_${GG}_PERSIST.dat"
"${FILEPATH}/${datenow}_wind_k6_evol_time_MNH_${GG}_PERSIST.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"WS_PERSIST_${datenow}.dat"
EOF
          rm -f ${JOB}
      fi

      if [ $(grep "BUFFER LENGTH = 5" "${FILEPATH}/${datenow}_winddir_k6_evol_time_AR_${GG}.dat"|wc -l) -eq 1 ]; then
          VARIABLE="WD-m/s"
          rm -f AAATMP
          tail -n+3 "${FILEPATH}/${datenow}_winddir_k6_evol_time_TELEMETRY_output_${GG}_PERSIST.dat" > AAATMP
          sed -e 's/NAN/9999.0/g' -i AAATMP
          rm -f ${JOBWD}
          ./exe90_debug ${JOBWD}
          ./${JOBWD}<<EOF > /dev/null 2>&1
"${datenow}"
"${FILEPATH}/${datenow}_winddir_k6_evol_time_AR_${GG}_PERSIST.dat"
"${FILEPATH}/${datenow}_winddir_k6_evol_time_MNH_${GG}_PERSIST.dat"
"AAATMP"
${MAXMIN}
${MINMIN}
"${VARIABLE}"
"WD_PERSIST_${datenow}.dat"
EOF
          rm -f ${JOBWD}
      fi

      rm -f AAATMP

    done

    rm ${LISTATMP} -f


#
    if [ $daygg == "night" ]; then
        LISTA="list_SEE.txt"
        ls SEE_PERSIST_*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
        LISTA="list_TAU.txt"
        ls TAU_PERSIST_*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
        LISTA="list_GLF.txt"
        ls GLF_PERSIST_*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
    fi
    LISTA="list_PWV.txt"
    ls PWV_PERSIST_*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
    LISTA="list_RH.txt"
    ls RH_PERSIST_*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
    LISTA="list_WS.txt"
    ls WS_PERSIST_*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
    LISTA="list_WD.txt"
    ls WD_PERSIST_*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
    
# _LastMonth TODO DA CAMBIARE OGNI MESE--------
    if [ $daygg == "night" ]; then
        LISTA="list_SEE_LastMonth.txt"
        ls SEE_PERSIST_202312*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
        LISTA="list_TAU_LastMonth.txt"
        ls TAU_PERSIST_202312*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
        LISTA="list_GLF_LastMonth.txt"
        ls GLF_PERSIST_202312*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
    fi
    LISTA="list_PWV_LastMonth.txt"
    ls PWV_PERSIST_202312*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
    LISTA="list_RH_LastMonth.txt"
    ls RH_PERSIST_202312*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
    LISTA="list_WS_LastMonth.txt"
    ls WS_PERSIST_202312*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}
    LISTA="list_WD_LastMonth.txt"
    ls WD_PERSIST_202312*.dat |cut -d"_" -f3|cut -d"." -f1|sort|uniq > $OUTPUTDIR/${LISTA}

#    
    if [ $daygg == "night" ]; then
        test -d "SEE_TREATED"|| mkdir "SEE_TREATED"
        mv SEE_PERSIST_*.dat "SEE_TREATED/"
        test -d "TAU_TREATED"|| mkdir "TAU_TREATED"
        mv TAU_PERSIST_*.dat "TAU_TREATED/"
        test -d "GLF_TREATED"|| mkdir "GLF_TREATED"
        mv GLF_PERSIST_*.dat "GLF_TREATED/"
    fi
    test -d "PWV_TREATED"|| mkdir "PWV_TREATED"
    mv PWV_PERSIST_*.dat "PWV_TREATED/"
    test -d "RH_TREATED"|| mkdir "RH_TREATED"
    mv RH_PERSIST_*.dat "RH_TREATED/"
    test -d "WS_TREATED"|| mkdir "WS_TREATED"
    mv WS_PERSIST_*.dat "WS_TREATED/"
    test -d "WD_TREATED"|| mkdir "WD_TREATED"
    mv WD_PERSIST_*.dat "WD_TREATED/"

#
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
exit 0

