#!/bin/bash

# Source of env file
envfile=$HOME'/NEWDEV/SCRIPTS/fate-report.env'
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
if [ -e "$SCRDIR/TMPL_LATEX/table_tmpl.tex" ]; then
  cp $SCRDIR/TMPL_LATEX/table_tmpl.tex $WRKDIR/table_skills_BEF.tex
  cp $SCRDIR/TMPL_LATEX/table_tmpl.tex $WRKDIR/table_skills_AFT.tex
else
  error "Cannot create temporary_tableBEF.tex. Exiting..."
fi

#################################################################
#                     BEFORE DATA (i.e. standard))
#                     GREP SKILLS FOR EACH VARIABLE
#################################################################

# Loop over the climatic variables
for prefix in ws wd rh pwv
do
  get_var_attr "$prefix"
  # BEFAFT DATA
  FILE_SKILLS=$WRKDIR/${skills_file}_BEFAFT_${prefix}
  BIAS=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep BEF | grep BIAS | cut -d '=' -f2`
  RMSE=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep BEF | grep RMSE | cut -d '=' -f2`
  SD=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep BEF | grep SIGMA | cut -d '=' -f2`
  # PERSISTENCE DATA
  FILE_SKILLS=$WRKDIR/${skills_file}_PER_${prefix}
  RMSE_PERS=`cat $FILE_SKILLS | grep LOGINFO | grep BEF | grep RMSE | cut -d '=' -f2`
  my_caption='Statistics for variables in standard configuration'
  cat $WRKDIR/table_skills_BEF.tex | sed -e "s!${prefixUC}BIAS!$BIAS!"    | \
                                     sed -e "s!${prefixUC}RMSE!$RMSE!"    | \
                                     sed -e "s!${prefixUC}SD!$SD!"        | \
                                     sed -e "s!${prefixUC}PERSRMSE!$RMSE_PERS!"        | \
                                     sed -e "s!TABCAPTION!$my_caption!"   \
                                     > $WRKDIR/table_tmpl_TEMP.tex
  mv $WRKDIR/table_tmpl_TEMP.tex $WRKDIR/table_skills_BEF.tex 
done

# Astro-climatic variable
for prefix in see tau glf
do
  get_var_attr "$prefix"
  case "$prefix" in
  see)
    FILE_SKILLS=$WRKDIR/${skills_file}_BEFAFT_${prefix}_0.24
   ;;
  tau)
    FILE_SKILLS=$WRKDIR/${skills_file}_BEFAFT_${prefix}_1.22
    ;;
  glf)
    FILE_SKILLS=$WRKDIR/${skills_file}_BEFAFT_${prefix}_0.14
    ;;
  *) echo "Lo sai chi ti saluta?"
     exit 1
     ;;
  esac
  BIAS=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep BEF | grep BIAS | cut -d '=' -f2`
  RMSE=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep BEF | grep RMSE | cut -d '=' -f2`
  SD=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep BEF | grep SIGMA | cut -d '=' -f2`
  # PERSISTENCE DATA
  FILE_SKILLS_PER=`echo $FILE_SKILLS | sed -e "s/_BEFAFT_/_PER_/g"`
  RMSE_PERS=`cat $FILE_SKILLS_PER | grep LOGINFO | grep BEF | grep RMSE | cut -d '=' -f2`
  cat $WRKDIR/table_skills_BEF.tex | sed -e "s!${prefixUC}BIAS!$BIAS!"    | \
                                     sed -e "s!${prefixUC}RMSE!$RMSE!"    | \
                                     sed -e "s!${prefixUC}SD!$SD!"        | \
                                     sed -e "s!${prefixUC}PERSRMSE!$RMSE_PERS!"        | \
                                     sed -e "s!TABCAPTION!$my_caption!"   \
                                     > $WRKDIR/table_tmpl_TEMP.tex
  mv $WRKDIR/table_tmpl_TEMP.tex $WRKDIR/table_skills_BEF.tex
done

#################################################################
#                     AFTER DATA (i.e. processed with AR)
#                     GREP SKILLS FOR EACH VARIABLE
#################################################################

# Loop over the climatic variables
for prefix in ws wd rh pwv
do
  get_var_attr "$prefix"
  # BEFAFT DATA
  FILE_SKILLS=$WRKDIR/${skills_file}_BEFAFT_${prefix}
  BIAS=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep AFT | grep BIAS | cut -d '=' -f2`
  RMSE=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep AFT | grep RMSE | cut -d '=' -f2`
  SD=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep AFT | grep SIGMA | cut -d '=' -f2`
  # PERSISTENCE DATA
  FILE_SKILLS=$WRKDIR/${skills_file}_PER_${prefix}
  RMSE_PERS=`cat $FILE_SKILLS | grep LOGINFO | grep AFT | grep RMSE | cut -d '=' -f2`
  my_caption='Statistics for variables processed with AR (1H)'
  cat $WRKDIR/table_skills_AFT.tex | sed -e "s!${prefixUC}BIAS!$BIAS!"    | \
                                     sed -e "s!${prefixUC}RMSE!$RMSE!"    | \
                                     sed -e "s!${prefixUC}SD!$SD!"        | \
                                     sed -e "s!${prefixUC}PERSRMSE!$RMSE_PERS!"        | \
                                     sed -e "s!TABCAPTION!$my_caption!"   \
                                     > $WRKDIR/table_tmpl_TEMP.tex
  mv $WRKDIR/table_tmpl_TEMP.tex $WRKDIR/table_skills_AFT.tex
done

# Astro-climatic variable
for prefix in see tau glf
do
############ ATT PER LA PERSISTENZA 
  get_var_attr "$prefix"
  case "$prefix" in
  see)
    FILE_SKILLS=$WRKDIR/${skills_file}_BEFAFT_${prefix}_0.24
   ;;
  tau)
    FILE_SKILLS=$WRKDIR/${skills_file}_BEFAFT_${prefix}_1.22
    ;;
  glf)
    FILE_SKILLS=$WRKDIR/${skills_file}_BEFAFT_${prefix}_0.14
    ;;
  *) echo "Lo sai chi ti saluta?"
     exit 1
     ;;
  esac
  BIAS=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep AFT | grep BIAS | cut -d '=' -f2`
  RMSE=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep AFT | grep RMSE | cut -d '=' -f2`
  SD=`cat $FILE_SKILLS | grep LOGINFO | grep ${prefixUC} | grep AFT | grep SIGMA | cut -d '=' -f2`
  # PERSISTENCE DATA
  FILE_SKILLS_PER=`echo $FILE_SKILLS | sed -e "s/_BEFAFT_/_PER_/g"`
  RMSE_PERS=`cat $FILE_SKILLS_PER | grep LOGINFO | grep AFT | grep RMSE | cut -d '=' -f2`
  cat $WRKDIR/table_skills_AFT.tex | sed -e "s!${prefixUC}BIAS!$BIAS!"    | \
                                     sed -e "s!${prefixUC}RMSE!$RMSE!"    | \
                                     sed -e "s!${prefixUC}SD!$SD!"        | \
                                     sed -e "s!${prefixUC}PERSRMSE!$RMSE_PERS!"        | \
                                     sed -e "s!TABCAPTION!$my_caption!"   \
                                     > $WRKDIR/table_tmpl_TEMP.tex
  mv $WRKDIR/table_tmpl_TEMP.tex $WRKDIR/table_skills_AFT.tex
done

#################################################################
notice "End of "`basename $0`
exit 0

