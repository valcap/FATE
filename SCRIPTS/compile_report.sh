#!/bin/bash

#################################################################
# Usage
#################################################################
if [ $# -ne 1 ]; then
  echo 'Not enough/too many arguments'
  echo "Usage: $0 env_file"
  echo "Example: $0 $HOME/SCRIPTS/fate-report.env"
  echo ""
  exit 1
else
  envfile=$1
fi

#################################################################
# Source of env file
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
rm -f `echo $report_tex_file | sed -e "s!tex!!"`*.*
cp $LOGOSDIR/INAF_Arcetri_colore.png $WRKDIR/
cp $LOGOSDIR/logo_lamma.png $WRKDIR/
cp $LOGOSDIR/fate_logo_11def.png $WRKDIR/
cp $fate_sty $WRKDIR/

cd $WRKDIR
# NIGHT 1
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night1.tex
echo '\section{Night 1}' >> night1.tex
# FIGURES
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > night1_figures.tex
echo '\subsection{Figures}' >> night1_figures.tex
cat figures_ws.tex figures_wd.tex figures_rh.tex figures_pwv.tex figures_see.tex figures_tau.tex figures_glf.tex >> night1_figures.tex 
echo '\clearpage' >> night1_figures.tex
# STATISTICS
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > night1_statistics.tex
echo '\subsection{Statistics}' >> night1_statistics.tex
cat table_skills_BEF.tex table_skills_AFT.tex >> night1_statistics.tex
echo '\clearpage' >> night1_statistics.tex
# CONTINGENCY TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night1_contingency.tex
echo '\subsection{Contingency tables}' >> night1_contingency.tex
cat contingency_tableBEFws.tex contingency_tableAFTws.tex >> night1_contingency.tex
cat contingency_tableBEFwd.tex contingency_tableAFTwd.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex 
cat contingency_tableBEFrh.tex contingency_tableAFTrh.tex >> night1_contingency.tex
cat contingency_tableBEFpwv.tex contingency_tableAFTpwv.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFsee_0.0.tex contingency_tableAFTsee_0.0.tex \
    contingency_tableBEFsee_0.24.tex contingency_tableAFTsee_0.24.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFtau_0.0.tex contingency_tableAFTtau_0.0.tex \
    contingency_tableBEFtau_1.22.tex contingency_tableAFTtau_1.22.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFglf_0.0.tex contingency_tableAFTglf_0.0.tex \
    contingency_tableBEFglf_0.14.tex contingency_tableAFTglf_0.14.tex >> night1_contingency.tex
# PODs TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night1_PODs.tex
echo '\subsection{PODs tables}' >> night1_PODs.tex
cat tablePODsws.tex tablePODswd.tex \
    tablePODsrh.tex tablePODspwv.tex >> night1_PODs.tex
echo '\clearpage' >> night1_PODs.tex
cat tablePODssee_0.0.tex tablePODssee_0.24.tex \
    tablePODstau_0.0.tex tablePODstau_1.22.tex \
    tablePODsglf_0.0.tex tablePODsglf_0.14.tex >> night1_PODs.tex


#################################################################
# TEMPLATE
# Check and modify the template Latex file
if [ ! -e $main_tmpl_file ]; then
  error "$main_tmpl_file doe not exist"
fi
export LC_TIME="en_US.UTF-8"
cat $main_tmpl_file | sed -e "s!TODAYDATESTRING!$TODAYDATESTRING!"    | \
                      sed -e "s!TODAYMONTHSTRING!$TODAYMONTHSTRING!"  | \
                      sed -e "s!TODAYYEARSTRING!$TODAYYEARSTRING!"    > $WRKDIR/main.tex
if [ $? != 0 ]; then
  error "Problem in creating $WRKDIR/main.tex file"
fi
if [ ! -f "$WRKDIR/main.tex" ]; then
  error "Cannot create $WRKDIR/main.tex. Exiting..."
fi

#################################################################
# COMPILING THE LATEX FILE
cd $WRKDIR
notice "Compiling the Latex file"
pdflatex main.tex > /dev/null 2>&1
pdflatex main.tex > /dev/null 2>&1
#pdflatex main.tex > /dev/null 2>&1
if [ $? != 0 ]; then
  error "Problem in compiling $WRKDIR/main.tex file"
else
  cp main.pdf $report_pdf_file
  if [ $? == 0 ]; then
    notice "OK $report_pdf_file"
  else
    error "Generic error in cp -v main.pdf $report_pdf_file"
  fi
fi

#################################################################
# exit
notice "End of "`basename $0`
exit 0
#################################################################






















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

# TODO SOLO PER PROVA DA RIMETTERE A POSTO IN MODALITA' OPERATIVA
cp /home/report/SCRIPTS/TMPL_LATEX/figure_empty.tex $WRKDIR/
if [ ! -e $fate_sty ]; then
  error "$fate_sty doe not exist"
else
  cp -v $fate_sty $REPORTDIR/
fi



#################################################################
#    $clearpage_file \
#    $clearpage_file \
#    $clearpage_file \
#    figure_empty.tex figure_empty.tex figure_empty.tex figure_empty.tex \
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
    contingency_tableBEFwd.tex contingency_tableAFTwd.tex \
    newpage.tex \
    $clearpage_file \
    contingency_tableBEFrh.tex contingency_tableAFTrh.tex \
    contingency_tableBEFpwv.tex contingency_tableAFTpwv.tex \
    newpage.tex \
    $clearpage_file \
    contingency_tableBEFsee_0.0.tex contingency_tableBEFsee_0.24.tex \
    contingency_tableAFTsee_0.0.tex contingency_tableAFTsee_0.24.tex \
    newpage.tex \
    $clearpage_file \
    contingency_tableBEFtau_0.0.tex contingency_tableBEFtau_1.22.tex  \
    contingency_tableAFTtau_0.0.tex contingency_tableAFTtau_1.22.tex  \
    newpage.tex \
    $clearpage_file \
    contingency_tableBEFglf_0.0.tex contingency_tableBEFglf_0.14.tex  \
    contingency_tableAFTglf_0.0.tex contingency_tableAFTglf_0.14.tex  \
    newpage.tex \
    $clearpage_file \
    tablePODsws.tex tablePODswd.tex tablePODsrh.tex tablePODspwv.tex \
    newpage.tex \
    $clearpage_file \
    tablePODssee_0.0.tex tablePODssee_0.24.tex \
    tablePODstau_0.0.tex tablePODstau_1.22.tex \
    tablePODsglf_0.0.tex tablePODsglf_0.14.tex \
    $clearpage_file \
    tableLOGs.tex \
    $tail_tmpl_file \
    > $report_tex_file 


#   $file_legend1 $file_legend2 $file_legend3 \
#    $clearpage_file \
#    $file_legend1 $file_legend2 $file_legend3 \
#    $clearpage_file \
#################################################################
# COMPILING THE LATEX FILE
cd /home/report/REPORT
notice "Compiling the Latex file"
latex $report_tex_file > /dev/null 2>&1
latex $report_tex_file > /dev/null 2>&1
notice "dvi2ps and ps2pdf"
# then dvi2ps
dvips `basename $report_tex_file .tex`.dvi > /dev/null 2>&1
# then ps2pdf
ps2pdf14 `basename $report_tex_file .tex`.ps > /dev/null 2>&1
for e in out ps aux log dvi 
do
  rm -f `basename $report_tex_file .tex`.$e
done
notice "byebye"

# exit
notice "End of "`basename $0`
exit 0

