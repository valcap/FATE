#! /bin/bash
export JOB=rh_mnh_ar_hit_def_stan
export IDELTA=10
export GG=5GG
export HH=1H
export STARTMINUTE=300  # from 19:00 LT
#export STARTMINUTE=0  # from 19:00 LT
export ENDMINUTE=960    # to 05:00 LT
#export ENDMINUTE=1080    # to 06:00 LT
export NbNights=354
export ROOT="/Users/masciadri/STEREO_SCIDAR/MNH/PERSIST_TREATED_365_20180801_20190731/${GG}/${HH}/RH_TREATED/"
export STARTIN="RH_PERSIST_"
export TAIL=".dat"
export MAXSEE=999.   # put 999. if one wants to consider the whole values without filtering
# ATT: only the option 999. is valid if one wish to calculate the contingency tables
rm -f ${JOB}
test -f out_scatter_for_python_bef.dat && rm -f out_scatter_for_python_bef.dat
test -f out_scatter_for_python_aft.dat && rm -f out_scatter_for_python_aft.dat
exe90mac_mod_check_new ${JOB}
./${JOB}<<EOF
${GG}
${HH}
${IDELTA}
${NbNights}
${STARTMINUTE}
${ENDMINUTE}
"${ROOT}"
"${TAIL}"
"${STARTIN}"
'list_RH_${GG}.txt'
'rh_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan.ps/cps'
'rh_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_stan.ps/cps'
EOF
python3 scatter_contour_rh.py out_scatter_for_python_bef.dat "OBS (%)" "MNH-stan (%)" "" 0. 100. 20.
python3 scatter_contour_rh.py out_scatter_for_python_aft.dat "OBS (%)" "AR (%)" "" 0. 100. 20.
mv out_scatter_for_python_bef.png rh_out_scatter_for_python_bef.png
mv out_scatter_for_python_aft.png rh_out_scatter_for_python_aft.png
