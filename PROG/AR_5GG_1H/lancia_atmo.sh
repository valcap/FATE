#!/bin/bash

#########################################
## Start of input arguments
#
if [ $# -ne 1 ]; then
  echo ""
  echo "Not enough/too many arguments"
  echo "Usage: ./$0 [ws | wd | rh | pwv]"
  echo "Example: ./$0 ws"
  echo "where ws=wind speed | wd=wind direction | rh=relative humidity | pwv=precipitable water vapor"
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
ws | wd | wd45 | rh | pwv)
#  echo ""
  echo "OK! input string is $VARIN"
  ;;
*)
  echo ""
  echo "KO! input string $VARIN is not recognised"
  echo "allowed values are ws | wd | rh | pwv"
  echo ""
  exit 1
  ;;
esac
#
## End of input arguments
#########################################

# Source of functions
funcfile='/home/report/scripts/functions.sh'
if [ -e $funcfile ]; then
  source $funcfile
else
  echo "ops $funcfile does not exist in "`pwd`; exit 1
fi

# Source of env file
envfile='/home/report/scripts/fate-report.env'
if [ -e $envfile ]; then
  source $envfile
else
  echo "ops $envfile does not exist in "`pwd`; exit 1
fi


#########################################
## Check directories 
#
if [ ! -d $DATA_ROOT_DIR ]; then
  echo "ops $DATA_ROOT_DIR is missing or is not a directory"; exit 1
fi
if [ ! -d $FIGS_ROOT_DIR ]; then
  echo "ops $FIGS_ROOT_DIR is missing or is not a directory"; exit 1
fi
if [ ! -d $PROG_ROOT_DIR ]; then
  echo "ops $PROG_ROOT_DIR is missing or is not a directory"; exit 1
fi
#
## End of check directories
#########################################

cd $PROG_ROOT_DIR

#########################################
# 1. Wind Speed (variable prefix is 'ws')

if [ $VARIN == 'ws' ]; then
  ## Start of local variables
  #
  prefix_lc='ws'
  PREFIX_UC='WS'
  export JOB=$prefix_lc'_mnh_ar_hit_def_stan'
  if [ ! -e ${JOB}.f90 ]; then
    echo "ops ${JOB}.f90 is missing"; exit 1
  fi
  export IDELTA=10
#  export STARTMINUTE=300  # from 19:00 LT
#  export ENDMINUTE=960    # to 06:00 LT
  export FILE_LIST="list_"$PREFIX_UC"_${GG}.txt"
  if [ ! -e $FILE_LIST ]; then
    echo "ops $FILE_LIST is missing in the current directory"; exit 1
  fi
  export NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
  export ROOT=$DATA_ROOT_DIR"/${PREFIX_UC}_TREATED/"
  if [ ! -d $ROOT ]; then
    echo "ops $ROOT is missing or is not a directory"; exit 1
  fi
  export STARTIN="${PREFIX_UC}_ARevol_"
  export TAIL=".dat"
  export LIMIT=0.     # limite inferiore da usarsi quando si vuole studiare lo scattering plot di WS sopra una certa soglia.
                      # Se si vuole considerare tutto il sample mettere LIMIT=0.
  export MAXWS=999.   # put 999. if one wants to consider the whole values without filtering
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
${LIMIT}
"${ROOT}"
"${TAIL}"
"${STARTIN}"
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan.ps/cps'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_stan.ps/cps'
EOF
  rm -f ${JOB}.exe
  rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
  #
  ## End of procedure for ws
fi

#############################################
# 2a. Wind Direction 0-90 (variable prefix is 'wd')

if [ $VARIN == 'wd' ]; then
  ## Start of local variables
  #
  prefix_lc='wd'
  PREFIX_UC='WD'
  export JOB=$prefix_lc'_mnh_ar_hit_def_stan_0_90'
  if [ ! -e ${JOB}.f90 ]; then
    echo "ops ${JOB}.f90 is missing"; exit 1
  fi
  export IDELTA=10
  export STARTMINUTE=300  # from 19:00 LT
  export ENDMINUTE=960    # to 06:00 LT
  export FILE_LIST="list_"$PREFIX_UC"_${GG}.txt"
  if [ ! -e $FILE_LIST ]; then
    echo "ops $FILE_LIST is missing in the current directory"; exit 1
  fi
  export NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
  export ROOT=$DATA_ROOT_DIR"/${PREFIX_UC}_TREATED/"
  if [ ! -d $ROOT ]; then
    echo "ops $ROOT is missing or is not a directory"; exit 1
  fi
  export ROOT_WS=$DATA_ROOT_DIR"/WS_TREATED/"
  export STARTIN=$PREFIX_UC"_ARevol_"
  export STARTIN_WS="WS_ARevol_"
  export TAIL=".dat"
  export LIMIT=3.          #export MAXSEE=999.   # put 999. if one wants to consider the whole values without filtering
                           # ATT: only the option 999. is valid if one wish to calculate the contingency tables
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
${LIMIT}
"${ROOT}"
"${ROOT_WS}"
"${TAIL}"
"${STARTIN}"
"${STARTIN_WS}"
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan_0_90.ps/cps'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_stan_0_90.ps/cps'
EOF
  rm -f ${JOB}.exe
  rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
  #
  ## End of procedure for wd
fi

#############################################
# 2b. Wind Direction 45-45 (variable prefix is 'wd')

if [ $VARIN == 'wd45' ]; then
## Start of local variables
#
prefix_lc='wd'
PREFIX_UC='WD'
export JOB=$prefix_lc'_mnh_ar_hit_def_stan_45_45'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
export IDELTA=10
export STARTMINUTE=300  # from 19:00 LT
export ENDMINUTE=960    # to 06:00 LT
export FILE_LIST="list_"$PREFIX_UC"_${GG}.txt"
if [ ! -e $FILE_LIST ]; then
  echo "ops $FILE_LIST is missing in the current directory"; exit 1
fi
export NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
export ROOT=$DATA_ROOT_DIR"/${PREFIX_UC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
export ROOT_WS=$DATA_ROOT_DIR"/WS_TREATED/"
export STARTIN=$PREFIX_UC"_ARevol_"
export STARTIN_WS="WS_ARevol_"
export TAIL=".dat"
export LIMIT=3.          #export MAXSEE=999.   # put 999. if one wants to consider the whole values without filtering
                         # ATT: only the option 999. is valid if one wish to calculate the contingency tables
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
${LIMIT}
"${ROOT}"
"${ROOT_WS}"
"${TAIL}"
"${STARTIN}"
"${STARTIN_WS}"
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan_45_45.ps/cps'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_stan_45_45.ps/cps'
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
#
## End of procedure for wd
fi

################################################
# 3. Relative humidity (variable prefix is 'rh')

if [ $VARIN == 'rh' ]; then
## Start of local variables
#
prefix_lc='rh'
PREFIX_UC='RH'
export JOB=$prefix_lc'_mnh_ar_hit_def_stan'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
export IDELTA=10
export STARTMINUTE=300  # from 19:00 LT
export ENDMINUTE=960    # to 05:00 LT
export FILE_LIST="list_"$PREFIX_UC"_${GG}.txt"
export NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
export ROOT=$DATA_ROOT_DIR"/${PREFIX_UC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
export STARTIN="${PREFIX_UC}_ARevol_"
export TAIL=".dat"
export MAXSEE=999.   # put 999. if one wants to consider the whole values without filtering
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

# Run .f90 file
./${JOB}.exe<<EOF > tmpfile_${VARIN}
${GG}
${HH}
${IDELTA}
${NbNights}
${STARTMINUTE}
${ENDMINUTE}
"${ROOT}"
"${TAIL}"
"${STARTIN}"
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan.ps/cps'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_stan.ps/cps'
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
#
## End of procedure for rh
fi

########################################################
# 4. Precipitable Water Vapor (variable prefix is 'pwv')

if [ $VARIN == 'pwv' ]; then
## Start of local variables
#
prefix_lc='pwv'
PREFIX_UC='PWV'
export JOB=$prefix_lc'_mnh_ar_hit_def_stan'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
export IDELTA=20
export STARTMINUTE=300  # from 19:00 LT
export ENDMINUTE=960    # to 05:00 LT
export FILE_LIST="list_"$PREFIX_UC"_${GG}.txt"
if [ ! -e $FILE_LIST ]; then
  echo "ops $FILE_LIST is missing in the current directory"; exit 1
fi
export NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
export ROOT=$DATA_ROOT_DIR"/${PREFIX_UC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
export STARTIN="${PREFIX_UC}_ARevol_"
export TAIL=".dat"
export MAXPWV=15.   # put 999. if one wants to consider the whole values without filtering
                    # ATT: only the option 999. is valid if one wish to calculate the contingency tables
#
## End of local variables

## Start of procedure for pwv
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
${MAXPWV}
"${ROOT}"
"${TAIL}"
"${STARTIN}"
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan.ps/cps'
'$FIGS_ROOT_DIR/${prefix_lc}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_stan.ps/cps'
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
#
## End of procedure for pwv
fi

exit 0;

