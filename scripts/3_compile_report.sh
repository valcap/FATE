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
# START OF STEP 2
# Use the outputs of the program by Elena to compile the latex file
notice "Start of "`basename $0`

#################################################################
# HOUSEKEEPING
rm -f `echo $report_tex_file | sed -e "s!tex!!"`*
rm -f $WRKDIR/body.tex
rm -f $WRKDIR/temporary_tableBEF.tex $WRKDIR/temporary_tableAFT.tex
cp $WRKDIR/TMPL_LATEX/table_tmpl.tex $WRKDIR/temporary_tableBEF.tex
cp $WRKDIR/TMPL_LATEX/table_tmpl.tex $WRKDIR/temporary_tableAFT.tex
cp $WRKDIR/TMPL_LATEX/contingency_tmpl.tex $WRKDIR/contingency_tableBEF.tex
cp $WRKDIR/TMPL_LATEX/contingency_tmpl.tex $WRKDIR/contingency_tableAFT.tex

#################################################################
# HEADER
# Modify here the header by using the template $header_tmpl_file
if [ ! -e $header_tmpl_file ]; then
  error "$header_tmpl_file doe not exist"
fi
cat $header_tmpl_file | sed -e "s!TODAYDOWSTRING!$TODAYDOWSTRING_CHILE!" | \
                        sed -e "s!TODAYSTRING!$TODAYSTRING_CHILE!"       | \
                        sed -e "s!TODAYTIMESTRING!$TODAYTIMESTRING_CHILE!" > $WRKDIR/header.tex
if [ $? != 0 ]; then
  error "Problem in creating header file"
fi
if [ ! -f "$WRKDIR/header.tex" ]; then
  notice "Ops..big problem"
  error "Cannot create header.tex. Exiting..."
fi

#################################################################
# NAME OF SECTION - FIGURES
cat << EOF > $WRKDIR/body.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\clearpage
\section{Figures for ${GG}-${HH}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF
sh $SCRDIR/3a_compile_report_FIGS.sh

#################################################################
# NAME OF SECTION - STATISTICS
cat << EOF >> $WRKDIR/body.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\clearpage
\section{Statistics for ${GG}-${HH}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF
sh $SCRDIR/3b_compile_report_STATS.sh

#################################################################
# NAME OF SECTION - CONTINGENCY TABLE
cat << EOF >> $WRKDIR/body.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\clearpage
\section{Contingency tables ${GG}-${HH}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF
sh $SCRDIR/3c_compile_report_CONTTAB.sh

#################################################################
# TAIL
# Modify here the tail (if any) by using the template $tail_tmpl_file
if [ ! -e $tail_tmpl_file ]; then
  error "$tail_tmpl_file doe not exist"
else
  cp $tail_tmpl_file $WRKDIR/tail.tex
fi

#################################################################
# HOUSEKEEPING
rm -f $PROG_ROOT_DIR/tmpfile_*
########################################################################

#################################################################
# Create the latex file by catting head, body and tail
cd $WRKDIR
cat temporary_tableBEF.tex \
    contingency_tableBEF.tex \
    temporary_tableAFT.tex \
    contingency_tableAFT.tex >> body.tex
cat header.tex body.tex tail.tex > $report_tex_file
rm -f temporary_tableBEF.tex temporary_tableAFT.tex
rm -f contingency_tableBEF.tex contingency_tableAFT.tex
rm -f header.tex body.tex tail.tex

# Compile twice latex (graphics are included as .eps file format)
cd $REPORTDIR
echo "Compiling $report_tex_file source"
latex $report_tex_file > /dev/null 2>&1
latex $report_tex_file > /dev/null 2>&1
# then dvi2ps
dvips `basename $report_tex_file .tex`.dvi > /dev/null 2>&1
# then ps2pdf
ps2pdf14 `basename $report_tex_file .tex`.ps > /dev/null 2>&1
if [ ! -e `basename $report_tex_file .tex`.pdf ]; then
  echo "ops `basename $report_tex_file .tex`.pdf not created!"
else
  echo "OK `basename $report_tex_file .tex`.pdf created, check it out!!!"
fi

#################################################################
notice "End of "`basename $0`
exit 0


















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
    unitof='\textit{add unit of measure}'
    suffix='stan'
    ;;
  *) echo "Lo sai chi ti saluta?"
     exit 1
     ;;
  esac	
  
  #################################################################
  # Now ingest the outputs of the program by Elena
  # into the latex file (both figures and statistics)

  ## Figures
  #
  cd $FIGS_ROOT_DIR
  PROG=1

  EPSBEF=$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.eps
  EPSAFT=$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.eps
  EPSPER=$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.eps
cat << EOF >> $WRKDIR/body.tex

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\clearpage
\begin{figure}
\begin{minipage}{.5\linewidth}
\centering
\subfloat[]{\includegraphics[width=.99\linewidth,angle=-90]{$EPSBEF}}
\end{minipage}%
\begin{minipage}{.5\linewidth}
\centering
\subfloat[]{\includegraphics[width=.99\linewidth,angle=-90]{$EPSAFT}}
\end{minipage}\par\medskip
\centering
\subfloat[]{\includegraphics[width=.5\linewidth,angle=-90]{$EPSPER}}
\caption{my fig}
\label{fig:main}
\end{figure}
EOF

  ## Statistics
  #
  cd $PROG_ROOT_DIR
  # BEFORE STUFF
  BIAS=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep BIAS | cut -d '=' -f2`
  RMSE=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep RMSE | cut -d '=' -f2`
  SD=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep SIGMA | cut -d '=' -f2`
  my_caption='Statistics for standard variables (i.e. BEF)'
  cat $WRKDIR/temporary_tableBEF.tex | sed -e "s!${prefixUC}BIAS!$BIAS!"    | \
                                    sed -e "s!${prefixUC}RMSE!$RMSE!"    | \
                                    sed -e "s!${prefixUC}SD!$SD!"        | \
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
  if [ ${prefix} = 'ws' ]; then
  ## Contingency
  #
  cd $PROG_ROOT_DIR
  # BEFORE STUFF
  PERC1=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW0 | awk '{print $6}'`
  PERC2=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW0 | awk '{print $9}'`
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
  cat $WRKDIR/contingency_tableBEF.tex | sed -e "s/PERC1/$PERC1/g"    | \
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
                                    sed -e "s!LONGVAR!$descri!"      \
                                    > $WRKDIR/contingency_table${PROG}BEF.tex
  mv $WRKDIR/contingency_table${PROG}BEF.tex $WRKDIR/contingency_tableBEF.tex
  if [ $? != 0 ]; then
    echo  "+++ "`date +%c`" Problem in creating table file"; exit 1;
  fi
  if [ ! -f "$WRKDIR/contingency_tableBEF.tex" ]; then
    echo "Ops..big problem"
    echo "Cannot create contingency_tableBEF.tex. Exiting..."
    exit 1;
  fi
  # AFTER STUFF
  PERC1=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW0 | awk '{print $6}'`
  PERC2=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW0 | awk '{print $9}'`
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
  cat $WRKDIR/contingency_tableAFT.tex | sed -e "s/PERC1/$PERC1/g"    | \
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
                                    sed -e "s!LONGVAR!$descri!"      \
                                    > $WRKDIR/contingency_table${PROG}AFT.tex
  mv $WRKDIR/contingency_table${PROG}AFT.tex $WRKDIR/contingency_tableAFT.tex
  if [ $? != 0 ]; then
    echo  "+++ "`date +%c`" Problem in creating table file"; exit 1;
  fi
  if [ ! -f "$WRKDIR/contingency_tableAFT.tex" ]; then
    echo "Ops..big problem"
    echo "Cannot create contingency_tableAFT.tex. Exiting..."
    exit 1;
  fi

  fi

  # AFTER STUFF
  BIAS=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep BIAS | cut -d '=' -f2`
  RMSE=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep RMSE | cut -d '=' -f2`
  SD=`cat tmpfile_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep SIGMA | cut -d '=' -f2`
  my_caption='Statistics for variables processed with AR (i.e. AFT)'
  cat $WRKDIR/temporary_tableAFT.tex | sed -e "s!${prefixUC}BIAS!$BIAS!"    | \
                                    sed -e "s!${prefixUC}RMSE!$RMSE!"    | \
                                    sed -e "s!${prefixUC}SD!$SD!"        | \
                                    sed -e "s!TABCAPTION!$my_caption!"   \
                                    > $WRKDIR/temporary_table${PROG}AFT.tex
  mv $WRKDIR/temporary_table${PROG}AFT.tex $WRKDIR/temporary_tableAFT.tex
  rm -f tmpfile_${prefix}
  if [ $? != 0 ]; then
    echo  "+++ "`date +%c`" Problem in creating table file"; exit 1;
  fi
  if [ ! -f "$WRKDIR/temporary_tableBEF.tex" ]; then
    echo "Ops..big problem"
    echo "Cannot create temporary_tableBEF.tex. Exiting..."
    exit 1;
  fi
done
rm -f $PROG_ROOT_DIR/tmpfile_*
cat $WRKDIR/temporary_tableBEF.tex $WRKDIR/contingency_tableBEF.tex $WRKDIR/temporary_tableAFT.tex $WRKDIR/contingency_tableAFT.tex >> $WRKDIR/body.tex
rm -f $WRKDIR/temporary_tableBEF.tex $WRKDIR/temporary_tableAFT.tex
rm -f $WRKDIR/contingency_tableBEF.tex $WRKDIR/contingency_tableAFT.tex
########################################################################

#################################################################
# Create the latex file by catting head, body and tail
cd $WRKDIR
cat header.tex body.tex tail.tex > $report_tex_file
rm -f header.tex body.tex tail.tex
# Compile twice latex (graphics are included as .eps file format)
cd $REPORTDIR
echo "Compiling $report_tex_file source"
latex $report_tex_file > /dev/null 2>&1
latex $report_tex_file > /dev/null 2>&1
# then dvi2ps
dvips `basename $report_tex_file .tex`.dvi > /dev/null 2>&1
# then ps2pdf
ps2pdf14 `basename $report_tex_file .tex`.ps > /dev/null 2>&1
if [ ! -e `basename $report_tex_file .tex`.pdf ]; then
  echo "ops `basename $report_tex_file .tex`.pdf not created!"
else
  echo "OK `basename $report_tex_file .tex`.pdf created, check it out!!!"
fi

#################################################################
notice "End of "`basename $0`
exit 0

