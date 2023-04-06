#!/bin/bash

############################################################################
# Usage
############################################################################
#if [ $# -ne 2 ]; then
#  echo "Not enough arguments"
#  echo "Usage: $0 env_file [00 or 12]"
#  echo "Example: $0 /home/lamma/scripts/etc/campo_regata/saipem.env 00"
#  echo ""
#  exit 1
#fi

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

#################################################################
# START OF STEP 1
# Run the program by Elena to produce graphics and statistics
# for [[BEF & AFT]]
# to be included in the central body of the report
notice "Start of "`basename $0`
rm -f $PROG_ROOT_DIR/tmpfile_*

# Loop over variables
for prefix in ws wd rh pwv see tau glf
do
  get_var_attr "$prefix"

  cd $PROG_ROOT_DIR
  if [ ! -e ./lancia_atmo.sh ]; then
    error "lancia_atmo.sh does not exist in $PROG_ROOT_DIR"
  fi
  if [ ! -e ./lancia_astro.sh ]; then
    error "lancia_astro.sh does not exist in $PROG_ROOT_DIR"
  fi

  if [[ ${prefix} = 'ws' || ${prefix} = 'rh' || ${prefix} = 'wd' || ${prefix} = 'pwv' ]]; then
    sh ./lancia_atmo.sh $prefix
  elif [[ ${prefix} = 'see' || ${prefix} = 'tau' || ${prefix} = 'glf' ]]; then
    sh ./lancia_astro.sh $prefix
  else
    error 'ops cannot run lancia_a* with '$prefix
  fi

  # check tmpfile file
  # a file named tmpfile_NAME-OF-THE-VARIABLE is expected in $PROG_ROOT_DIR
  if [ ! -e $PROG_ROOT_DIR/tmpfile_${prefix} ]; then
    notice "$PROG_ROOT_DIR/tmpfile_${prefix} not produced"
    error "ops $PROG_ROOT_DIR/lancia_atmo.sh ${prefix} didnt work"
  fi

  # check .ps files
  # .ps files (see naming below) are also expected in $FIGS_ROOT_DIR
  if [ ! -e $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps ]; then
    notice "ops $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps not produced"
    error "ops $PROG_ROOT_DIR/lancia_atmo.sh ${prefix} didnt work"
  else
    cp $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.eps
    rm -f $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps
  fi
  if [ ! -e $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps ]; then
    notice "ops $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps not produced"
    error "ops $PROG_ROOT_DIR/lancia_atmo.sh ${prefix} didnt work";
  else
    cp $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.eps
    rm -f $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps
  fi
done

# End of program
notice "End of "`basename $0`
exit 0
# END OF STEP 1
#################################################################

