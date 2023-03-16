#! /bin/bash
export JOB=see_mnh_ar_hit_def_os18_1000
export IDELTA=10
export GG=5GG
export HH=1H
export STARTMINUTE=300  # from 19:00 LT
#export STARTMINUTE=0  # from 19:00 LT
export ENDMINUTE=960    # to 06:00 LT
#export ENDMINUTE=1080    # to 06:00 LT
export NbNights=348
export ACC=0.24          # accuracy for the seeing
export ROOT="/Users/masciadri/STEREO_SCIDAR/MNH/PERSIST_TREATED_365_20180801_20190731/${GG}/${HH}/SEE_TREATED/"
export STARTIN="SEE_PERSIST_"
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
${MAXSEE}
${ACC}
"${ROOT}"
"${TAIL}"
"${STARTIN}"
'list_SEE_${GG}.txt'
'see_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_os18_1000.ps/cps'
'see_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_os18_1000.ps/cps'
EOF
python3 scatter_contour_see.py out_scatter_for_python_bef.dat "Seeing (arcsec) - DIMM" "Seeing (arcsec) - MNH" "" 0 2.5 0.5
python3 scatter_contour_see.py out_scatter_for_python_aft.dat "Seeing (arcsec) - DIMM" "Seeing (arcsec) - MNH-AR" "" 0 2.5 0.5
mv out_scatter_for_python_bef.png see_os18_1000_out_scatter_for_python_bef.png
mv out_scatter_for_python_aft.png see_os18_1000_out_scatter_for_python_aft.png
