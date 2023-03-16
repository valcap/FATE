#! /bin/bash
export JOB=tau0_mnh_ar_hit_def_os18_1000
export IDELTA=10
export GG=5GG
export HH=1H
export STARTMINUTE=300  # from 19:00 LT
export ENDMINUTE=960    # to 06:00 LT
export NbNights=347
export ACC=1.22          # accuracy for the tau0
export ROOT="/Users/masciadri/STEREO_SCIDAR/MNH/PERSIST_TREATED_365_20180801_20190731/${GG}/${HH}/TAU_TREATED/"
export STARTIN="TAU_PERSIST_"
export TAIL=".dat"
export MAXTAU=999.   # put 999. if one wants to consider the whole values without filtering
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
${MAXTAU}
${ACC}
"${ROOT}"
"${TAIL}"
"${STARTIN}"
'list_TAU_${GG}.txt'
'tau0_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_os18_1000.ps/cps'
'tau0_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_os18_1000.ps/cps'
EOF
python3 scatter_contour_tau.py out_scatter_for_python_bef.dat "Tau0 (ms) - MASS-DIMM " "Tau0 (ms) - MNH" "" 0 20 5
python3 scatter_contour_tau.py out_scatter_for_python_aft.dat "Tau0 (ms) - MASS-DIMM " "Tau0 (ms) - MNH-AR" "" 0 20 5
mv out_scatter_for_python_bef.png tau_os18_1000_out_scatter_for_python_bef.png
mv out_scatter_for_python_aft.png tau_os18_1000_out_scatter_for_python_aft.png

