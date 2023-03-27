#! /bin/bash
export JOB=glf_mnh_ar_hit_def_os18
export IDELTA=10
export GG=5GG
export HH=1H
export STARTMINUTE=300  # from 19:00 LT
export ENDMINUTE=960    # to 06:00 LT
export NbNights=347
export ACC=0.14          # accuracy for the glf
export ROOT="/Users/masciadri/STEREO_SCIDAR/MNH/PERSIST_TREATED_365_20180801_20190731/${GG}/${HH}/GLF_TREATED/"
export STARTIN="GLF_PERSIST_"
export TAIL=".dat"
export MAXGLF=999.   # put 999. if one wants to consider the whole values without filtering
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
${MAXGLF}
${ACC}
"${ROOT}"
"${TAIL}"
"${STARTIN}"
'list_GLF_${GG}.txt'
'glf_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_os18.ps/cps'
'glf_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_os18.ps/cps'
EOF
python3 scatter_contour_glf.py out_scatter_for_python_bef.dat "GLF - OBS" "GLF - MNH" "" 0. 1.0 0.2
python3 scatter_contour_glf.py out_scatter_for_python_aft.dat "GLF - OBS" "GLF - MNH-AR" "" 0. 1.0 0.2
mv out_scatter_for_python_bef.png glf_os18_out_scatter_for_python_bef.png
mv out_scatter_for_python_aft.png glf_os18_out_scatter_for_python_aft.png
