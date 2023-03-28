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
rm -f `echo $report_tex_file | sed -e "s!tex!!"`*
rm -f $WRKDIR/body.tex
rm -f $WRKDIR/temporary_tableBEF.tex $WRKDIR/temporary_tableAFT.tex
cp $WRKDIR/TMPL_LATEX/table_tmpl.tex $WRKDIR/temporary_tableBEF.tex
cp $WRKDIR/TMPL_LATEX/table_tmpl.tex $WRKDIR/temporary_tableAFT.tex
#cp $WRKDIR/TMPL_LATEX/contingency_tmpl.tex $WRKDIR/contingency_tableBEF.tex
#cp $WRKDIR/TMPL_LATEX/contingency_tmpl.tex $WRKDIR/contingency_tableAFT.tex

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
  for ext in toc out aux log dvi ps
  do
    rm -f `basename $report_tex_file .tex`.$ext
  done
fi

#################################################################
notice "End of "`basename $0`
exit 0

