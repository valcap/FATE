#!/bin/bash

#########################################
## Start of input arguments
#
if [ $# -ne 1 ]; then
  echo ""
  echo "Not enough/too many arguments"
  echo "Usage: ./$0 [see | tau | glf]"
  echo "Example: ./$0 ws"
  echo "where see=seeing | tau=coherence time | glf=glf"
  echo ""
  exit 1
else
  VARIN=$1
fi
if [[ -z $VARIN ]]; then
  echo ""
  echo "KO! The input string is empty."
  echo ""
  exit 1
fi
case $VARIN in
see | tau | glf )
  echo "OK! input string is $VARIN"
  ;;
*)
  echo ""
  echo "KO! input string $VARIN is not recognised"
  echo "allowed values are see | tau | glf"
  echo ""
  exit 1
  ;;
esac
#
## End of input arguments
#########################################

# Source of env file
envfile='/home/report/scripts/fate-report.env'
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

#########################################
## Check directories 
#
if [ ! -d $DATA_PERS_DIR ]; then
  echo "ops $DATA_PERS_DIR is missing or is not a directory"; exit 1
fi
if [ ! -d $FIGS_ROOT_DIR ]; then
  echo "ops $FIGS_ROOT_DIR is missing or is not a directory"; exit 1
fi
if [ ! -d $PERS_ROOT_DIR ]; then
  echo "ops $PERS_ROOT_DIR is missing or is not a directory"; exit 1
fi
#
## End of check directories
#########################################

cd $PERS_ROOT_DIR

#########################################
# 1. Seeing (variable prefix is 'see')

if [ $VARIN == 'see' ]; then
## Start of local variables
#
prefix_lc='see'
PREFIX_UC='SEE'
export JOB=$prefix_lc'_mnh_ar_hit_def_os18_1000'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
export IDELTA=10
export FILE_LIST="list_"$PREFIX_UC"_${GG}.txt"
if [ ! -e $FILE_LIST ]; then
  echo "ops $FILE_LIST is missing in the current directory"; exit 1
fi
export NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
export ACC=0.24        # accuracy for the seeing insturments  (for seeing without filtering 1.5" we have accuacry =0.45")
export ROOT=$DATA_PERS_DIR"/${PREFIX_UC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
export STARTIN="${PREFIX_UC}_PERSIST_"
export TAIL=".dat"
export MAXSEE=999.   # put 999. if one wants to consider the whole values without filtering
                    # ATT: use the option 999 if you wish to calculate the contingency tables
#
## End of local variables

## Start of procedure for ws
#
rm -f ${JOB}.exe
test -f out_scatter_for_python_bef.dat && rm -f out_scatter_for_python_bef.dat
test -f out_scatter_for_python_aft.dat && rm -f out_scatter_for_python_aft.dat
# Compile f90 file
gfortran -Wall -fbounds-check -o ${JOB}.exe ${JOB}.f90 -I/home/report/bin/NUMREC -I/home/report/bin/LIBPERSO/mod -L/home/report/bin/LIBPERSO -L/home/report/bin/NUMREC -J/home/report/bin/NUMREC -lpgplot -lpng -lz -lpers -lnumrec > /dev/null 2>&1
if [ ! -e ${JOB}.exe ]; then
  echo "ops problem in compiling ${JOB}.f90"; exit 1
fi

# Run f90 file
./${JOB}.exe<<EOF > tmpfile_${VARIN}
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
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_os18_1000_per.ps/cps'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_os18_1000_per.ps/cps'
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
#
## End of procedure for ws
fi

#############################################
# 2. coherence time (variable prefix is 'tau')

if [ $VARIN == 'tau' ]; then
## Start of local variables
#
prefix_lc='tau'
PREFIX_UC='TAU'
export JOB=$prefix_lc'0_mnh_ar_hit_def_os18_1000'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
export IDELTA=10
export FILE_LIST="list_"$PREFIX_UC"_${GG}.txt"
if [ ! -e $FILE_LIST ]; then
  echo "ops $FILE_LIST is missing in the current directory"; exit 1
fi
export NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
export ACC=1.22          # accuracy for the tau0 (slide 12 instruments_vs_instruments_new_pipeline)
export ROOT=$DATA_PERS_DIR"/${PREFIX_UC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
export STARTIN=$PREFIX_UC"_PERSIST_"
export TAIL=".dat"
export MAXTAU=999.   # put 999. if one wants to consider the whole values without filtering

#
## End of local variables

## Start of procedure for wd
#
rm -f ${JOB}.exe
test -f out_scatter_for_python_bef.dat && rm -f out_scatter_for_python_bef.dat
test -f out_scatter_for_python_aft.dat && rm -f out_scatter_for_python_aft.dat
# Compile f90 file
gfortran -Wall -fbounds-check -o ${JOB}.exe ${JOB}.f90 -I/home/report/bin/NUMREC -I/home/report/bin/LIBPERSO/mod -L/home/report/bin/LIBPERSO -L/home/report/bin/NUMREC -J/home/report/bin/NUMREC -lpgplot -lpng -lz -lpers -lnumrec > /dev/null 2>&1
if [ ! -e ${JOB}.exe ]; then
  echo "ops problem in compiling ${JOB}.f90"; exit 1
fi

# Run f90 file
./${JOB}.exe<<EOF > tmpfile_${VARIN}
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
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_os18_1000_per.ps/cps'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_os18_1000_per.ps/cps'
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
#
## End of procedure for wd
fi

################################################
# 3. glfboh (variable prefix is 'glf')

if [ $VARIN == 'glf' ]; then
## Start of local variables
#
prefix_lc='glf'
PREFIX_UC='GLF'
export JOB=$prefix_lc'_mnh_ar_hit_def_os18'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
export IDELTA=10
export FILE_LIST="list_"$PREFIX_UC"_${GG}.txt"
export NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
export ACC=0.14          # accuracy for the glf (isntruments_vs_instrument_new+_pipeline slide 14)
export ROOT=$DATA_PERS_DIR"/${PREFIX_UC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
export STARTIN="${PREFIX_UC}_PERSIST_"
export TAIL=".dat"
export MAXGLF=999.   # put 999. if one wants to consider the whole values without filtering
                     # ATT: only the option 999. is valid if one wish to calculate the contingency tables
#
## End of local variables

## Start of procedure for rh
#
rm -f ${JOB}.exe
test -f out_scatter_for_python_bef.dat && rm -f out_scatter_for_python_bef.dat
test -f out_scatter_for_python_aft.dat && rm -f out_scatter_for_python_aft.dat
gfortran -Wall -fbounds-check -o ${JOB}.exe ${JOB}.f90 -I/home/report/bin/NUMREC -I/home/report/bin/LIBPERSO/mod -L/home/report/bin/LIBPERSO -L/home/report/bin/NUMREC -J/home/report/bin/NUMREC -lpgplot -lpng -lz -lpers -lnumrec > /dev/null 2>&1
if [ ! -e ${JOB}.exe ]; then
  echo "ops problem in compiling ${JOB}.f90"; exit 1
fi

# Run .exe file
./${JOB}.exe<<EOF > tmpfile_${VARIN}
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
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan_per.ps/cps'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_stan_per.ps/cps'
TRUE
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
#
## End of procedure for rh
fi

exit 0;

