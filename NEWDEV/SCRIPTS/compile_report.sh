#!/bin/bash

#################################################################
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

notice "Start of "`basename $0`

#################################################################
# HOUSEKEEPING
rm -f `echo $report_tex_file | sed -e "s!tex!!"`*
#
cat << EOF > $WRKDIR/sec5.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{BOH}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF
#
cat << EOF > $WRKDIR/linea.tex

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\begin{center}
\HRule \\\\[0.4cm]
%\end{center}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EOF
#
cat << EOF > $WRKDIR/newpage.tex

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\\newpage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EOF

#################################################################
# HEADER
# Modify here the header by using the template $header_tmpl_file
if [ ! -e $header_tmpl_file ]; then
  error "$header_tmpl_file doe not exist"
fi
export LC_TIME="en_US.UTF-8"
cat $header_tmpl_file | sed -e "s!TODAYDOWSTRING!$TODAYDOWSTRING_CHILE!" | \
                        sed -e "s!TODAYSTRING!$TODAYSTRING_CHILE!"       | \
                        sed -e "s!TODAYTIMESTRING!$TODAYTIMESTRING_CHILE!" > $WRKDIR/header.tex
if [ $? != 0 ]; then
  error "Problem in creating header file"
fi
if [ ! -f "$WRKDIR/header.tex" ]; then
  error "Cannot create header.tex. Exiting..."
fi

#################################################################
#    $clearpage_file \
#    $clearpage_file \
#    $clearpage_file \
# CATTING HEADER + BODY + TAIL
cd $WRKDIR
cat header.tex \
    figures_ws.tex figures_wd.tex figures_rh.tex figures_pwv.tex figures_see.tex figures_tau.tex figures_glf.tex \
    newpage.tex \
    $clearpage_file \
    table_skills_BEF.tex table_skills_AFT.tex \
    newpage.tex \
    $clearpage_file \
    contingency_tableBEFws.tex contingency_tableAFTws.tex \
    contingency_tableBEFrh.tex contingency_tableAFTrh.tex \
    contingency_tableBEFpwv.tex contingency_tableAFTpwv.tex \
    $clearpage_file \
    contingency_tableBEFsee_0.0.tex contingency_tableBEFsee_0.10.tex contingency_tableBEFsee_0.24.tex \
    contingency_tableAFTsee_0.0.tex contingency_tableAFTsee_0.10.tex contingency_tableAFTsee_0.24.tex \
    contingency_tableBEFtau_0.0.tex contingency_tableBEFtau_1.22.tex  \
    contingency_tableAFTtau_0.0.tex contingency_tableAFTtau_1.22.tex  \
    contingency_tableBEFglf_0.0.tex contingency_tableBEFglf_0.14.tex  \
    contingency_tableAFTglf_0.0.tex contingency_tableAFTglf_0.14.tex  \
    $clearpage_file \
    newpage.tex \
    $clearpage_file \
    tablePODsws.tex tablePODsrh.tex tablePODspwv.tex \
    tablePODssee_0.0.tex tablePODssee_0.10.tex tablePODssee_0.24.tex \
    tablePODstau_0.0.tex tablePODstau_1.22.tex \
    tablePODsglf_0.0.tex tablePODsglf_0.14.tex \
    $tail_tmpl_file \
    > $report_tex_file 

#################################################################
# COMPILING THE LATEX FILE
cd /home/report/REPORT
notice "Compiling the Latex file then dvi2ps then ps2pdf"
latex $report_tex_file #> /dev/null 2>&1
latex $report_tex_file #> /dev/null 2>&1
# then dvi2ps
dvips `basename $report_tex_file .tex`.dvi > /dev/null 2>&1
# then ps2pdf
ps2pdf14 `basename $report_tex_file .tex`.ps > /dev/null 2>&1
notice "byebye"

exit 1




















#################################################################
# NAME OF SECTION - FIGURES
sh $SCRDIR/3a_compile_report_FIGS.sh

#################################################################
# NAME OF SECTION - STATISTICS
sh $SCRDIR/3b_compile_report_STATS.sh

#################################################################
# NAME OF SECTION - CONTINGENCY TABLE
sh $SCRDIR/3c_compile_report_CONTTAB.sh

#################################################################
# NAME OF SECTION - PODs TABLE
sh $SCRDIR/3d_compile_report_PODs.sh

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
cat << EOF >> $WRKDIR/body.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\clearpage
\section{Statistics for ${GG}-${HH}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF
cat temporary_tableBEF.tex \
    temporary_tableAFT.tex >> body.tex
cat << EOF >> $WRKDIR/body.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\clearpage
\section{Contingency tables ${GG}-${HH}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF
cat contingency_tableBEF.tex \
    contingency_tableAFT.tex  >> body.tex
cat << EOF >> $WRKDIR/body.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\clearpage
\section{PODs table ${GG}-${HH}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF
cat temporary_tablePODs.tex >> body.tex

# cat sections head, body and tail to the final output file
cat header.tex body.tex tail.tex > $report_tex_file
rm -f temporary_tableBEF.tex temporary_tableAFT.tex
rm -f contingency_tableBEF.tex contingency_tableAFT.tex
rm -f temporary_tablePODs.tex
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

