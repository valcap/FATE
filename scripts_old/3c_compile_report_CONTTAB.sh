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
for prefix in ws rh pwv see tau glf
do
  get_var_attr $prefix
  
  #################################################################
  # Now ingest the outputs of the program by Elena
  # into the latex file (both figures and statistics)

  cp $WRKDIR/TMPL_LATEX/contingency_tmpl.tex $WRKDIR/contingency_tableBEF${prefix}.tex
  cp $WRKDIR/TMPL_LATEX/contingency_tmpl.tex $WRKDIR/contingency_tableAFT${prefix}.tex

  cd $PROG_ROOT_DIR
  PROG=1

  # BEFORE STUFF
  PERC1=`cat tmpfile_${prefix} | grep LOGINFO | grep PERCENTILES | grep X33_ | awk '{print $4}'`
  PERC2=`cat tmpfile_${prefix} | grep LOGINFO | grep PERCENTILES | grep X66_ | awk '{print $4}'`
  SAMPLESIZE=`cat tmpfile_${prefix} | grep LOGINFO | grep BEF | grep NbLines_TOT | cut -d '=' -f2`
  VAL1=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $5}'`
  VAL2=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $6}'`
  VAL3=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $7}'`
  VAL4=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $5}'`
  VAL5=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $6}'`
  VAL6=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $7}'`
  VAL7=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $5}'`
  VAL8=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $6}'`
  VAL9=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $7}'`
  POD1=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD1 | awk '{print $5}'`
  POD2=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD2 | awk '{print $5}'`
  POD3=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD3 | awk '{print $5}'`
  PC=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep PC | awk '{print $5}'`
  EBD=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep EBD | awk '{print $5}'`
  my_nice_caption='Contingency table for variable '$descri' ('$unitof') in standard configuration (i.e. BEF)'
  cat $WRKDIR/contingency_tableBEF${prefix}.tex | sed -e "s/PERC1/$PERC1/g"    | \
                                    sed -e "s/PERC2/$PERC2/g"    | \
                                    sed -e "s/UNITVAR/$unitof/g"    | \
                                    sed -e "s!VAL1!$VAL1!"    | \
                                    sed -e "s!VAL2!$VAL2!"    | \
                                    sed -e "s!VAL3!$VAL3!"    | \
                                    sed -e "s!VAL4!$VAL4!"    | \
                                    sed -e "s!VAL5!$VAL5!"    | \
                                    sed -e "s!VAL6!$VAL6!"    | \
                                    sed -e "s!VAL7!$VAL7!"    | \
                                    sed -e "s!VAL8!$VAL8!"    | \
                                    sed -e "s!VAL9!$VAL9!"    | \
                                    sed -e "s!POD1!$POD1!"    | \
                                    sed -e "s!POD2!$POD2!"    | \
                                    sed -e "s!POD3!$POD3!"    | \
                                    sed -e "s!SAMPLESIZE!$SAMPLESIZE!"    | \
                                    sed -e "s!PCIS!$PC!"           | \
                                    sed -e "s!EBDIS!$EBD!"         | \
                                    sed -e "s/SHORTVAR/$prefix/g"  | \
                                    sed -e "s!LONGVAR!$descri!"    |  \
                                    sed -e "s!MYNICECAPTION!$my_nice_caption!" \
                                    > $WRKDIR/contingency_tableBEF${PROG}.tex
  mv $WRKDIR/contingency_tableBEF${PROG}.tex $WRKDIR/contingency_tableBEF${prefix}.tex
  if [ $? != 0 ]; then
    echo  "+++ "`date +%c`" Problem in creating table file"; exit 1;
  fi
  if [ ! -f "$WRKDIR/contingency_tableBEF${prefix}.tex" ]; then
    echo "Ops..big problem"
    echo "Cannot create contingency_tableBEF${prefix}.tex. Exiting..."
    exit 1;
  fi

  # AFTER STUFF
  PERC1=`cat tmpfile_${prefix} | grep LOGINFO | grep PERCENTILES | grep X33_ | awk '{print $4}'`
  PERC2=`cat tmpfile_${prefix} | grep LOGINFO | grep PERCENTILES | grep X66_ | awk '{print $4}'`
  SAMPLESIZE=`cat tmpfile_${prefix} | grep LOGINFO | grep AFT | grep NbLines_TOT | cut -d '=' -f2`
  VAL1=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW1 | awk '{print $5}'`
  VAL2=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW1 | awk '{print $6}'`
  VAL3=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW1 | awk '{print $7}'`
  VAL4=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW2 | awk '{print $5}'`
  VAL5=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW2 | awk '{print $6}'`
  VAL6=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW2 | awk '{print $7}'`
  VAL7=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW3 | awk '{print $5}'`
  VAL8=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW3 | awk '{print $6}'`
  VAL9=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW3 | awk '{print $7}'`
  POD1=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep POD1 | awk '{print $5}'`
  POD2=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep POD2 | awk '{print $5}'`
  POD3=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep POD3 | awk '{print $5}'`
  PC=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep PC | awk '{print $5}'`
  EBD=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep EBD | awk '{print $5}'`
  my_nice_caption='Contingency table for variable '$descri' ('$unitof') processed with AR (i.e. AFT)'
  cat $WRKDIR/contingency_tableAFT${prefix}.tex | sed -e "s/PERC1/$PERC1/g"    | \
                                    sed -e "s/PERC2/$PERC2/g"    | \
                                    sed -e "s/UNITVAR/$unitof/g"    | \
                                    sed -e "s!VAL1!$VAL1!"    | \
                                    sed -e "s!VAL2!$VAL2!"    | \
                                    sed -e "s!VAL3!$VAL3!"    | \
                                    sed -e "s!VAL4!$VAL4!"    | \
                                    sed -e "s!VAL5!$VAL5!"    | \
                                    sed -e "s!VAL6!$VAL6!"    | \
                                    sed -e "s!VAL7!$VAL7!"    | \
                                    sed -e "s!VAL8!$VAL8!"    | \
                                    sed -e "s!VAL9!$VAL9!"    | \
                                    sed -e "s!POD1!$POD1!"    | \
                                    sed -e "s!POD2!$POD2!"    | \
                                    sed -e "s!POD3!$POD3!"    | \
                                    sed -e "s!SAMPLESIZE!$SAMPLESIZE!"    | \
                                    sed -e "s!PCIS!$PC!"           | \
                                    sed -e "s!EBDIS!$EBD!"         | \
                                    sed -e "s/SHORTVAR/$prefix/g"  | \
                                    sed -e "s!LONGVAR!$descri!"    | \
                                    sed -e "s!MYNICECAPTION!$my_nice_caption!" \
                                    > $WRKDIR/contingency_tableAFT${PROG}.tex
  mv $WRKDIR/contingency_tableAFT${PROG}.tex $WRKDIR/contingency_tableAFT${prefix}.tex
  if [ $? != 0 ]; then
    echo  "+++ "`date +%c`" Problem in creating table file"; exit 1;
  fi
  if [ ! -f "$WRKDIR/contingency_tableAFT${prefix}.tex" ]; then
    echo "Ops..big problem"
    echo "Cannot create contingency_tableAFT${prefix}.tex. Exiting..."
    exit 1;
  fi
  cat $WRKDIR/contingency_tableBEF${prefix}.tex >> $WRKDIR/contingency_tableBEF.tex
  cat $WRKDIR/contingency_tableAFT${prefix}.tex >> $WRKDIR/contingency_tableAFT.tex
  rm -f $WRKDIR/contingency_tableBEF${prefix}.tex
  rm -f $WRKDIR/contingency_tableAFT${prefix}.tex
done

#################################################################
notice "End of "`basename $0`
exit 0

