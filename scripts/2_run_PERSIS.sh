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
  cd $PERS_ROOT_DIR
  if [ ! -e ./lancia_atmo_persi.sh ]; then
    error "lancia_atmo.sh does not exist in $PERS_ROOT_DIR"
  fi
  if [ ! -e ./lancia_astro_persi.sh ]; then
    error "lancia_astro.sh does not exist in $PERS_ROOT_DIR"
  fi
  case "$prefix" in
  ws)  
    prefixUC='WS'
    descri='Wind speed'
    unitof='$m s^{-1}$'
    suffix='stan_per'
    sh ./lancia_atmo_persi.sh $prefix
    ;;
  wd) 
    prefixUC='WD'
    descri='Wind direction'
    unitof='degree'
    suffix='stan_0_90_per'
    sh ./lancia_atmo_persi.sh $prefix
    ;;
  rh)
    prefixUC='RH'
    descri='Relative humidity'
    unitof='\%'
    suffix='stan_per'
    sh ./lancia_atmo_persi.sh $prefix
    ;;
  pwv) 
    prefixUC='PWV'
    descri='Precipitable water vapor'
    unitof='mm'
    suffix='stan_per'
    sh ./lancia_atmo_persi.sh $prefix
    ;;
  see) 
    prefixUC='SEE'
    descri='Total Seeing'
    unitof='arcsec'
    suffix='os18_1000_per'
    sh ./lancia_astro_persi.sh $prefix
    ;;
  tau) 
    prefixUC='TAU'
    descri='Coeherence time'
    unitof='ms'
    suffix='os18_1000_per'
    sh ./lancia_astro_persi.sh $prefix
    ;;
  glf) 
    prefixUC='GLF'
    descri='Ground layer fraction'
    unitof='\textit{add unit of measure}'
    suffix='stan_per'
    sh ./lancia_astro_persi.sh $prefix
    ;;
  *) echo "Lo sai chi ti saluta?"
     exit 1
     ;;
  esac  
#############################################
  
  # check tmpfile file
  # a file named tmpfile_NAME-OF-THE-VARIABLE is expected in $PROG_ROOT_DIR
  if [ ! -e $PERS_ROOT_DIR/tmpfile_${prefix} ]; then
    notice "$PERS_ROOT_DIR/tmpfile_${prefix} not produced"
    error "ops $PERS_ROOT_DIR/lancia_atmo.sh ${prefix} didnt work"
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

