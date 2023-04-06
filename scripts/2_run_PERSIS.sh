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

#################################################################
# START OF STEP 1
# Run the program by Elena to produce graphics and statistics
# for [[BEF & AFT]]
# to be included in the central body of the report
notice "Start of "`basename $0`
rm -f $PERS_ROOT_DIR/tmpfile_*

# Loop over variables
for prefix in ws wd rh pwv see tau glf
do
  get_var_attr "$prefix" 

  cd $PERS_ROOT_DIR
  if [ ! -e ./lancia_atmo_persi.sh ]; then
    error "lancia_atmo.sh does not exist in $PERS_ROOT_DIR"
  fi
  if [ ! -e ./lancia_astro_persi.sh ]; then
    error "lancia_astro.sh does not exist in $PERS_ROOT_DIR"
  fi

  if [[ ${prefix} = 'ws' || ${prefix} = 'rh' || ${prefix} = 'wd' || ${prefix} = 'pwv' ]]; then
    sh ./lancia_atmo_persi.sh $prefix
  elif [[ ${prefix} = 'see' || ${prefix} = 'tau' || ${prefix} = 'glf' ]]; then
    sh ./lancia_astro_persi.sh $prefix
  else
    error 'ops cannot run lancia_a* with '$prefix
  fi
  
  # check tmpfile file
  # a file named tmpfile_NAME-OF-THE-VARIABLE is expected in $PROG_ROOT_DIR
  if [ ! -e $PERS_ROOT_DIR/tmpfile_${prefix} ]; then
    notice "$PERS_ROOT_DIR/tmpfile_${prefix} not produced"
    error "ops $PERS_ROOT_DIR/lancia_atmo.sh ${prefix} didnt work"
  fi

  # check .ps files
  # .ps files (see naming below) are also expected in $FIGS_ROOT_DIR
  if [ ! -e $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}_per.ps ]; then
    notice "ops $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}_per.ps not produced"
    error "ops $PROG_ROOT_DIR/lancia_atmo.sh ${prefix} didnt work"
  else
    cp $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}_per.ps $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}_per.eps
    rm -f $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}_per.ps
  fi
  if [ ! -e $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.ps ]; then
    notice "ops $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.ps not produced"
    error "ops $PROG_ROOT_DIR/lancia_atmo.sh ${prefix} didnt work";
  else
    cp $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.ps $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.eps
    rm -f $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.ps
  fi
done

# End of program
notice "End of "`basename $0`
exit 0
# END OF STEP 1
#################################################################

