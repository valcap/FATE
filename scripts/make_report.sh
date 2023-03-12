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
#if [ ! -f $1 ]; then
#  echo "Usage: $0 env_file [00 or 12]"
#  echo "Example: $0 /home/lamma/scripts/etc/campo_regata/saipem.env 00"
#  echo ""
#  echo "Argument 1 was $1"
#  exit 1;
#fi
#if [ $2 != "00" ] && [ $2 != "12" ]; then
#  echo "Usage: $0 env_file [00 or 12]"
#  echo "Example: $0 /home/lamma/scripts/etc/campo_regata/saipem.env 00"
#  echo ""
#  echo "Argument 2 was $2"
#  exit 1;
#fi

GG='5GG'
HH='1H'
STARTMINUTE=300  # from 19:00 LT
ENDMINUTE=960    # to 06:00 LT
WRKDIR=$HOME'/scripts'
REPORTDIR=$HOME'/REPORT'
FIGSDIR=$HOME"/FIGS/$GG/$HH"
PROGDIR=$HOME"/PROG/AR_${GG}_${HH}"
header_tmpl_file=$WRKDIR'/TMPL_LATEX/header_tmpl.tex'
tail_tmpl_file=$WRKDIR'/TMPL_LATEX/tail_tmpl.tex'
TODAYSTRING=`date +"%d-%m-%Y" --date "today"`
TODAYDOWSTRING=`date +"%a" --date "today"`
TODAYDOWSTRINGL=`date +"%A" --date "today"`
TODAYTIMESTRING=`date +"%H%M" --date "today"`
TODAYSTRING_CHILE=`TZ='America/Santiago'     date +"%d-%m-%Y" --date "now"`
TODAYDOWSTRING_CHILE=`TZ='America/Santiago'  date +"%a"       --date "now"`
TODAYDOWSTRINGL_CHILE=`TZ='America/Santiago' date +"%A"       --date "now"`
TODAYTIMESTRING_CHILE=`TZ='America/Santiago' date +"%H:%M"    --date "now"`

# Start of procedure
echo "Start of "`basename $0`
fout=$REPORTDIR/FATE-REPORT_${TODAYSTRING}.tex
rm -f $REPORTDIR/FATE-REPORT_${TODAYSTRING}.*

#################################################################
# Modify here the header by using the template $header_tmpl_file
if [ ! -e $header_tmpl_file ]; then
  exit 1
fi
cat $header_tmpl_file | sed -e "s!TODAYDOWSTRING!$TODAYDOWSTRING_CHILE!" | \
                        sed -e "s!TODAYSTRING!$TODAYSTRING_CHILE!"       | \
                        sed -e "s!TODAYTIMESTRING!$TODAYTIMESTRING_CHILE!" > $WRKDIR/header.tex
if [ $? != 0 ]; then
  echo  "+++ "`date +%c`" Problem in creating header file"; exit 1;
fi
if [ ! -f "$WRKDIR/header.tex" ]; then
  echo "Ops..big problem"
  echo "Cannot create header.tex. Exiting..."
  exit 1;
fi
#################################################################
# Modify here the tail (if any) by using the template $tail_tmpl_file
if [ ! -e $tail_tmpl_file ]; then
  exit 1
fi
cp $tail_tmpl_file $WRKDIR/tail.tex

#################################################################
# Housekeeping
rm -f $WRKDIR/body.tex
rm -f $WRKDIR/temporary_tableBEF.tex $WRKDIR/temporary_tableAFT.tex
cp $WRKDIR/TMPL_LATEX/table_tmpl.tex $WRKDIR/temporary_tableBEF.tex
cp $WRKDIR/TMPL_LATEX/table_tmpl.tex $WRKDIR/temporary_tableAFT.tex
cat << EOF > $WRKDIR/body.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\clearpage
\section{Data for $GG $HH}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF
#################################################################
# Now run the program by Elena to produce graphics and statistics
# to be included in the central body of the report

# Loop over variables
for prefix in ws wd rh pwv see tau glf
do
  cd $PROGDIR
  rm -f $PROGDIR/stoca_*
  case "$prefix" in
  ws)  
    prefixUC='WS'
    descri='Wind speed ($m s^{-1}$)'
    suffix='stan'
    sh ./lancia_atmo.sh $prefix
    ;;
  wd) 
    prefixUC='WD'
    descri='Wind direction (degree)'
    suffix='stan_0_90'
    sh ./lancia_atmo.sh $prefix
    ;;
  rh)
    prefixUC='RH'
    descri='Relative humidity (\%)'
    suffix='stan'
    sh ./lancia_atmo.sh $prefix
    ;;
  pwv) 
    prefixUC='PWV'
    descri='Precipitable water vapor (mm)'
    suffix='stan'
    sh ./lancia_atmo.sh $prefix
    ;;
  see) 
    prefixUC='SEE'
    descri='Total Seeing (arcsec)'
    suffix='os18_1000'
    sh ./lancia_astro.sh $prefix
    ;;
  tau) 
    prefixUC='TAU'
    descri='Coeherence time (ms)'
    suffix='os18_1000'
    sh ./lancia_astro.sh $prefix
    ;;
  glf) 
    prefixUC='GLF'
    descri='Ground layer fraction \textit{(add unit of measure)}'
    suffix='stan'
    sh ./lancia_astro.sh $prefix
    ;;
  *) echo "stoca"
     exit 1
     ;;
  esac  
  # check if outputs were produced
  # a file named stoca_NAME-OF-THE-VARIABLE is expected in $PROGDIR
  # .ps files (see naming below) are also expected in $FIGSDIR
  # check stoca file
  if [ ! -e $PROGDIR/stoca_${prefix} ]; then
    echo "$PROGDIR/stoca_${prefix} not produced"
    echo "ops $PROGDIR/lancia_atmo.sh ${prefix} didnt work"
    exit 1
  fi

  # check .ps files
  if [ ! -e $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps ]; then
    echo "ops $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps not produced"
    echo "ops $PROGDIR/lancia_atmo.sh ${prefix} didnt work"
    exit 1
  else
    cp $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.eps
    rm -f $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps
  fi
  if [ ! -e $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps ]; then
    echo "ops $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps not produced"
    echo "ops $PROGDIR/lancia_atmo.sh ${prefix} didnt work";
    exit 1
  else
    cp $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.eps
    rm -f $FIGSDIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps
  fi
  
  #################################################################
  # Now ingest the outputs of the program by Elena
  # into the latex file (both figures and statistics)

  ## Figures
  #
  cd $FIGSDIR
  PROG=1
  for FILEEPS  in `ls ${prefix}_sim_mnh_ar_dimm_*${suffix}.eps`
  do
cat << EOF >> $WRKDIR/body.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage

\begin{center}
\textbf{$descri}
\end{center}

\begin{figure}[htbp]
\centering
{\includegraphics[scale=0.99,angle=-90]{$FIGSDIR/$FILEEPS}}
\caption{${prefix} - ${descri}}\label{fig:${prefix}${PROG}}
\end{figure}
EOF
  PROG=$((PROG+1))
  done

  ## Statistics
  #
  cd $PROGDIR
  # BEFORE STUFF
  BIAS=`cat stoca_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep BIAS | cut -d '=' -f2`
  RMSE=`cat stoca_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep RMSE | cut -d '=' -f2`
  SD=`cat stoca_${prefix} | grep LOGINFO | grep ${prefixUC} | grep BEF | grep SIGMA | cut -d '=' -f2`
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
  # AFTER STUFF
  BIAS=`cat stoca_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep BIAS | cut -d '=' -f2`
  RMSE=`cat stoca_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep RMSE | cut -d '=' -f2`
  SD=`cat stoca_${prefix} | grep LOGINFO | grep ${prefixUC} | grep AFT | grep SIGMA | cut -d '=' -f2`
  my_caption='Statistics for variables processed with AR (i.e. AFT)'
  cat $WRKDIR/temporary_tableAFT.tex | sed -e "s!${prefixUC}BIAS!$BIAS!"    | \
                                    sed -e "s!${prefixUC}RMSE!$RMSE!"    | \
                                    sed -e "s!${prefixUC}SD!$SD!"        | \
                                    sed -e "s!TABCAPTION!$my_caption!"   \
                                    > $WRKDIR/temporary_table${PROG}AFT.tex
  mv $WRKDIR/temporary_table${PROG}AFT.tex $WRKDIR/temporary_tableAFT.tex
  rm -f stoca_${prefix}
  if [ $? != 0 ]; then
    echo  "+++ "`date +%c`" Problem in creating table file"; exit 1;
  fi
  if [ ! -f "$WRKDIR/temporary_tableBEF.tex" ]; then
    echo "Ops..big problem"
    echo "Cannot create temporary_tableBEF.tex. Exiting..."
    exit 1;
  fi
done
rm -f $PROGDIR/stoca_*
cat $WRKDIR/temporary_tableBEF.tex $WRKDIR/temporary_tableAFT.tex >> $WRKDIR/body.tex
rm -f $WRKDIR/temporary_tableBEF.tex $WRKDIR/temporary_tableAFT.tex
########################################################################

#################################################################
# Create the latex file by catting head, body and tail
cd $WRKDIR
cat header.tex body.tex tail.tex > $fout
rm -f header.tex body.tex tail.tex
# Compile twice latex (graphics are included as .eps file format)
cd $REPORTDIR
echo "Compiling $fout source"
latex $fout > /dev/null 2>&1
latex $fout > /dev/null 2>&1
# then dvi2ps
dvips `basename $fout .tex`.dvi > /dev/null 2>&1
# then ps2pdf
ps2pdf14 `basename $fout .tex`.ps > /dev/null 2>&1
if [ ! -e `basename $fout .tex`.pdf ]; then
  echo "ops `basename $fout .tex`.pdf not created!"
else
  echo "OK `basename $fout .tex`.pdf created, check it out!!!"
fi

#################################################################
exit 0

