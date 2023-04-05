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
# START OF STEP 2
# Use the outputs of the program by Elena to compile the latex file
notice "Start of "`basename $0`

#################################################################
# HOUSEKEEPING

#################################################################
# CENTRAL BODY OF THE DOCUMENT

# Loop over variables
for prefix in ws wd rh pwv see tau glf
do
  case "$prefix" in
  ws)
    prefixUC='WS'
    descri='Wind speed'
    unitof='$m s^{-1}$'
    suffix='stan'
    ;;
  wd)
    prefixUC='WD'
    descri='Wind direction'
    unitof='degree'
    suffix='stan_0_90'
    ;;
  rh)
    prefixUC='RH'
    descri='Relative humidity'
    unitof='\%'
    suffix='stan'
    ;;
  pwv)
    prefixUC='PWV'
    descri='Precipitable water vapor'
    unitof='mm'
    suffix='stan'
    ;;
  see)
    prefixUC='SEE'
    descri='Total seeing'
    unitof='arcsec'
    suffix='os18_1000'
    ;;
  tau)
    prefixUC='TAU'
    descri='Coeherence time'
    unitof='ms'
    suffix='os18_1000'
    ;;
  glf)
    prefixUC='GLF'
    descri='Ground layer fraction'
    unitof='\textit{no unit of measure}'
    suffix='stan'
    ;;
  *) echo "Lo sai chi ti saluta?"
     exit 1
     ;;
  esac	
  
  #################################################################
  # Now ingest the outputs of the program by Elena
  # into the latex file

  ## Statistics
  #
  cd $PROG_ROOT_DIR
  PROG=1

  # BEFORE STUFF
  BIAS=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep BIAS | cut -d '=' -f2`
  RMSE=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep RMSE | cut -d '=' -f2`
  SD=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep SIGMA | cut -d '=' -f2`
  # PERSISTENCE (RMSE only)
#  cd $PERS_ROOT_DIR
#  RMSE_PERS=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep RMSE | cut -d '=' -f2`
  
  my_caption='Statistics for variables in standard configuration (i.e. BEF)'
  cat $WRKDIR/temporary_tableBEF.tex | sed -e "s!${prefixUC}BIAS!$BIAS!"    | \
                                    sed -e "s!${prefixUC}RMSE!$RMSE!"    | \
                                    sed -e "s!${prefixUC}SD!$SD!"        | \
#                                    sed -e "s!${prefixUC}PERSRMSE!$RMSE_PERS!"        | \
                                    sed -e "s!TABCAPTION!$my_caption!"   \
                                    > $WRKDIR/temporary_table${PROG}BEF.tex
  mv $WRKDIR/temporary_table${PROG}BEF.tex $WRKDIR/temporary_tableBEF.tex
  if [ $? != 0 ]; then
    echo  "+++ "`date +%c`" Problem in creating table file"; exit 1;
  fi
  if [ ! -f "$WRKDIR/temporary_tableBEF.tex" ]; then
    echo "Ops..big problem"
    echo "Cannot create temporary_tableBEF.tex. Exiting..."
    exit 1;
  fi

  # AFTER STUFF
  BIAS=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep BIAS | cut -d '=' -f2`
  RMSE=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep RMSE | cut -d '=' -f2`
  SD=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep SIGMA | cut -d '=' -f2`
  # PERSISTENCE (RMSE only)
#  cd $PERS_ROOT_DIR
#  RMSE_PERS=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep RMSE | cut -d '=' -f2`
  my_caption='Statistics for variables processed with AR (i.e. AFT)'
  cat $WRKDIR/temporary_tableAFT.tex | sed -e "s!${prefixUC}BIAS!$BIAS!"    | \
                                    sed -e "s!${prefixUC}RMSE!$RMSE!"    | \
                                    sed -e "s!${prefixUC}SD!$SD!"        | \
#                                    sed -e "s!${prefixUC}PERSRMSE!$RMSE_PERS!"        | \
                                    sed -e "s!TABCAPTION!$my_caption!"   \
                                    > $WRKDIR/temporary_table${PROG}AFT.tex
  mv $WRKDIR/temporary_table${PROG}AFT.tex $WRKDIR/temporary_tableAFT.tex
  if [ $? != 0 ]; then
    echo  "+++ "`date +%c`" Problem in creating table file"; exit 1;
  fi
  if [ ! -f "$WRKDIR/temporary_tableBEF.tex" ]; then
    echo "Ops..big problem"
    echo "Cannot create temporary_tableBEF.tex. Exiting..."
    exit 1;
  fi
done

#################################################################
notice "End of "`basename $0`
exit 0

