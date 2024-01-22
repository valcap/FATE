#!/bin/bash

############################################################################
# Usage
############################################################################
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

######################
# NIGHT 1
if [ ! -d $WRKDIR/night1 ]; then
  mkdir $WRKDIR/night1
fi
cd $WRKDIR/night1
# NIGHT 1
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night1.tex
echo '\section{Title for Night 1}' >> night1.tex
echo '\Blindtext[2] ' >> night1.tex
cp night1.tex $WRKDIR/
# FIGURES
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > night1_figures.tex
echo '\subsection{Title for Figures of Night 1}' >> night1_figures.tex
echo '\Blindtext[3] ' >> night1_figures.tex 
cat figures_ws.tex figures_wd.tex figures_rh.tex figures_pwv.tex figures_see.tex figures_tau.tex figures_glf.tex >> night1_figures.tex 
cp night1_figures.tex $WRKDIR/
# STATISTICS
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > night1_statistics.tex
echo '\subsection{Title for Statistics of Night 1}' >> night1_statistics.tex
echo '\Blindtext[4] ' >> night1_statistics.tex
cat table_skills_BEF.tex table_skills_AFT-LASTM.tex table_skills_AFT.tex >> night1_statistics.tex
echo '\clearpage' >> night1_statistics.tex
cp night1_statistics.tex $WRKDIR/
# CONTINGENCY TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night1_contingency.tex
echo '\subsection{Title for Contingency tables of Night 1}' >> night1_contingency.tex
echo '\Blindtext[3] ' >> night1_contingency.tex 
cat contingency_tableBEFws.tex contingency_tableAFTws.tex contingency_tableAFTws_FT.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFwd.tex contingency_tableAFTwd.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFrh.tex contingency_tableAFTrh.tex contingency_tableAFTrh_FT.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFpwv.tex contingency_tableAFTpwv.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFsee_0.0.tex contingency_tableAFTsee_0.0.tex >> night1_contingency.tex 
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFsee_0.24.tex contingency_tableAFTsee_0.24.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFtau_0.0.tex contingency_tableAFTtau_0.0.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat   contingency_tableBEFtau_1.22.tex contingency_tableAFTtau_1.22.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cat contingency_tableBEFglf_0.0.tex contingency_tableAFTglf_0.0.tex >> night1_contingency.tex 
echo '\clearpage' >> night1_contingency.tex
cat   contingency_tableBEFglf_0.14.tex contingency_tableAFTglf_0.14.tex >> night1_contingency.tex
echo '\clearpage' >> night1_contingency.tex
cp night1_contingency.tex $WRKDIR/
# PODs TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night1_PODs.tex
echo '\subsection{Title for PODs tables of Night 1}' >> night1_PODs.tex
echo '\Blindtext[3] ' >> night1_PODs.tex
cat tablePODsws.tex tablePODsws_FT.tex tablePODswd.tex >> night1_PODs.tex
echo '\clearpage' >> night1_PODs.tex
cat tablePODsrh.tex tablePODsrh_FT.tex tablePODspwv.tex >> night1_PODs.tex
echo '\clearpage' >> night1_PODs.tex
cat tablePODssee_0.0.tex tablePODssee_0.24.tex >> night1_PODs.tex
echo '\clearpage' >> night1_PODs.tex
cat tablePODstau_0.0.tex tablePODstau_1.22.tex >> night1_PODs.tex
echo '\clearpage' >> night1_PODs.tex
cat tablePODsglf_0.0.tex tablePODsglf_0.14.tex >> night1_PODs.tex
cp night1_PODs.tex $WRKDIR/

######################
# DAY 1
if [ ! -d $WRKDIR/day1 ]; then
  mkdir $WRKDIR/day1
fi
cd $WRKDIR/day1
# DAY 1
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > day1.tex
echo '\section{Title for Day 1}' >> day1.tex
echo '\Blindtext[2] ' >> day1.tex
cp day1.tex $WRKDIR/
# FIGURES
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > day1_figures.tex
echo '\subsection{Title for Figures of Day 1}' >> day1_figures.tex
echo '\Blindtext[3] ' >> day1_figures.tex
cat figures_ws.tex figures_wd.tex figures_rh.tex figures_pwv.tex >> day1_figures.tex
cp day1_figures.tex $WRKDIR/
# STATISTICS
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > day1_statistics.tex
echo '\subsection{Title for Statistics of Day 1}' >> day1_statistics.tex
echo '\Blindtext[4] ' >> day1_statistics.tex
cat table_skills_BEF.tex table_skills_AFT-LASTM.tex table_skills_AFT.tex >> day1_statistics.tex
#cat table_skills_BEF.tex >> day1_statistics.tex
echo '\clearpage' >> day1_contingency.tex
cp day1_statistics.tex $WRKDIR/
# CONTINGENCY TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > day1_contingency.tex
echo '\subsection{Title for Contingency tables of Day 1}' >> day1_contingency.tex
echo '\Blindtext[3] ' >> day1_contingency.tex
cat contingency_tableBEFws.tex contingency_tableAFTws.tex contingency_tableAFTws_FT.tex >> day1_contingency.tex
echo '\clearpage' >> day1_contingency.tex
cat contingency_tableBEFwd.tex contingency_tableAFTwd.tex >> day1_contingency.tex
echo '\clearpage' >> day1_contingency.tex
cat contingency_tableBEFrh.tex contingency_tableAFTrh.tex contingency_tableAFTrh_FT.tex >> day1_contingency.tex
echo '\clearpage' >> day1_contingency.tex
cat contingency_tableBEFpwv.tex contingency_tableAFTpwv.tex >> day1_contingency.tex
echo '\clearpage' >> day1_contingency.tex
cp day1_contingency.tex $WRKDIR/
echo '\clearpage' >> day1_contingency.tex
# PODs TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > day1_PODs.tex
echo '\subsection{Title for PODs tables of Day 1}' >> day1_PODs.tex
echo '\Blindtext[3] ' >> day1_PODs.tex
cat tablePODsws.tex tablePODsws_FT.tex tablePODswd.tex \
    tablePODsrh.tex tablePODsrh_FT.tex tablePODspwv.tex >> day1_PODs.tex
cp day1_PODs.tex $WRKDIR/

######################
# NIGHT2
cd $WRKDIR/night2
# TITLE
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night2.tex
echo '\section{Title for Night 2}' >> night2.tex
echo '\Blindtext[2] ' >> night2.tex
cp night2.tex $WRKDIR/
# FIGURES
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > night2_figures.tex
echo '\subsection{Title for Figures of Night 2}' >> night2_figures.tex
echo '\Blindtext[3] ' >> night2_figures.tex
cat figures_ws.tex figures_wd.tex figures_rh.tex figures_pwv.tex figures_see.tex figures_tau.tex figures_glf.tex >> night2_figures.tex
cp night2_figures.tex $WRKDIR/
# STATISTICS
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > night2_statistics.tex
echo '\subsection{Title for Statistics of Night 2}' >> night2_statistics.tex
echo '\Blindtext[4] ' >> night2_statistics.tex
cat table_skills_BEF.tex  >> night2_statistics.tex
cp night2_statistics.tex $WRKDIR/
# CONTINGENCY TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night2_contingency.tex
echo '\subsection{Title for Contingency tables of Night 2}' >> night2_contingency.tex
echo '\Blindtext[3] ' >> night2_contingency.tex
cat contingency_tableBEFws.tex >> night2_contingency.tex
cat contingency_tableBEFwd.tex >> night2_contingency.tex
cat contingency_tableBEFrh.tex >> night2_contingency.tex
cat contingency_tableBEFpwv.tex >> night2_contingency.tex
echo '\clearpage' >> night2_contingency.tex
cat contingency_tableBEFsee_0.0.tex >> night2_contingency.tex
cat contingency_tableBEFsee_0.24.tex >> night2_contingency.tex
cat contingency_tableBEFtau_0.0.tex >> night2_contingency.tex
cat contingency_tableBEFtau_1.22.tex >> night2_contingency.tex
echo '\clearpage' >> night2_contingency.tex
cat contingency_tableBEFglf_0.0.tex >> night2_contingency.tex
cat contingency_tableBEFglf_0.14.tex >> night2_contingency.tex
cp night2_contingency.tex $WRKDIR/
# PODs TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night2_PODs.tex
echo '\subsection{Title for PODs tables of Night 2}' >> night2_PODs.tex
echo '\Blindtext[3] ' >> night2_PODs.tex
cat tablePODsws.tex tablePODswd.tex \
    tablePODsrh.tex tablePODspwv.tex >> night2_PODs.tex
cat tablePODssee_0.0.tex tablePODssee_0.24.tex \
    tablePODstau_0.0.tex tablePODstau_1.22.tex \
    tablePODsglf_0.0.tex tablePODsglf_0.14.tex >> night2_PODs.tex
cp night2_PODs.tex $WRKDIR/

######################
# DAY 2
cd $WRKDIR/day2
# TITLE
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > day2.tex
echo '\section{Title for Day 2}' >> day2.tex
echo '\Blindtext[2] ' >> day2.tex
cp day2.tex $WRKDIR/
# FIGURES
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > day2_figures.tex
echo '\subsection{Title for Figures of Day 2}' >> day2_figures.tex
echo '\Blindtext[3] ' >> day2_figures.tex
cat figures_ws.tex figures_wd.tex figures_rh.tex figures_pwv.tex  >> day2_figures.tex
cp day2_figures.tex $WRKDIR/
# STATISTICS
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > day2_statistics.tex
echo '\subsection{Title for Statistics of Day 2}' >> day2_statistics.tex
echo '\Blindtext[4] ' >> day2_statistics.tex
cat table_skills_BEF.tex  >> day2_statistics.tex
cp day2_statistics.tex $WRKDIR/
# CONTINGENCY TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > day2_contingency.tex
echo '\subsection{Title for Contingency tables of Day 2}' >> day2_contingency.tex
echo '\Blindtext[3] ' >> day2_contingency.tex
cat contingency_tableBEFws.tex >> day2_contingency.tex
cat contingency_tableBEFwd.tex >> day2_contingency.tex
cat contingency_tableBEFrh.tex >> day2_contingency.tex
cat contingency_tableBEFpwv.tex >> day2_contingency.tex
echo '\clearpage' >> day2_contingency.tex
cp day2_contingency.tex $WRKDIR/
# PODs TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > day2_PODs.tex
echo '\subsection{Title for PODs tables of Day 2}' >> day2_PODs.tex
echo '\Blindtext[3] ' >> day2_PODs.tex
cat tablePODsws.tex tablePODswd.tex \
    tablePODsrh.tex tablePODspwv.tex >> day2_PODs.
cp day2_PODs.tex $WRKDIR/

######################
# NIGHT3
cd $WRKDIR/night3
# TITLE
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night3.tex
echo '\section{Title for Night 3}' >> night3.tex
echo '\Blindtext[2] ' >> night3.tex
cp night3.tex $WRKDIR/
# FIGURES
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > night3_figures.tex
echo '\subsection{Title for Figures of Night 3}' >> night3_figures.tex
echo '\Blindtext[3] ' >> night3_figures.tex
cat figures_ws.tex figures_wd.tex figures_rh.tex figures_pwv.tex figures_see.tex figures_tau.tex figures_glf.tex >> night3_figures.tex
cp night3_figures.tex $WRKDIR/
# STATISTICS
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > night3_statistics.tex
echo '\subsection{Title for Statistics of Night 3}' >> night3_statistics.tex
echo '\Blindtext[4] ' >> night3_statistics.tex
cat table_skills_BEF.tex  >> night3_statistics.tex
cp night3_statistics.tex $WRKDIR/
# CONTINGENCY TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night3_contingency.tex
echo '\subsection{Title for Contingency tables of Night 3}' >> night3_contingency.tex
echo '\Blindtext[3] ' >> night3_contingency.tex
cat contingency_tableBEFws.tex >> night3_contingency.tex
cat contingency_tableBEFwd.tex >> night3_contingency.tex
cat contingency_tableBEFrh.tex >> night3_contingency.tex
cat contingency_tableBEFpwv.tex >> night3_contingency.tex
echo '\clearpage' >> night3_contingency.tex
cat contingency_tableBEFsee_0.0.tex >> night3_contingency.tex
cat contingency_tableBEFsee_0.24.tex >> night3_contingency.tex
cat contingency_tableBEFtau_0.0.tex >> night3_contingency.tex
cat contingency_tableBEFtau_1.22.tex >> night3_contingency.tex
echo '\clearpage' >> night3_contingency.tex
cat contingency_tableBEFglf_0.0.tex >> night3_contingency.tex
cat contingency_tableBEFglf_0.14.tex >> night3_contingency.tex
cp night3_contingency.tex $WRKDIR/
# PODs TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > night3_PODs.tex
echo '\subsection{Title for PODs tables of Night 3}' >> night3_PODs.tex
echo '\Blindtext[3] ' >> night3_PODs.tex
cat tablePODsws.tex tablePODswd.tex \
    tablePODsrh.tex tablePODspwv.tex >> night3_PODs.tex
cat tablePODssee_0.0.tex tablePODssee_0.24.tex \
    tablePODstau_0.0.tex tablePODstau_1.22.tex \
    tablePODsglf_0.0.tex tablePODsglf_0.14.tex >> night3_PODs.tex
cp night3_PODs.tex $WRKDIR/

######################
# DAY 3
cd $WRKDIR/day3
# TITLE
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > day3.tex
echo '\section{Title for Day 3}' >> day3.tex
echo '\Blindtext[2] ' >> day3.tex
cp day3.tex $WRKDIR/
# FIGURES
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > day3_figures.tex
echo '\subsection{Title for Figures of Day 3}' >> day3_figures.tex
echo '\Blindtext[3] ' >> day3_figures.tex
cat figures_ws.tex figures_wd.tex figures_rh.tex figures_pwv.tex  >> day3_figures.tex
cp day3_figures.tex $WRKDIR/
# STATISTICS
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" > day3_statistics.tex
echo '\subsection{Title for Statistics of Day 3}' >> day3_statistics.tex
echo '\Blindtext[4] ' >> day3_statistics.tex
cat table_skills_BEF.tex  >> day3_statistics.tex
cp day3_statistics.tex $WRKDIR/
# CONTINGENCY TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > day3_contingency.tex
echo '\subsection{Title for Contingency tables of Day 3}' >> day3_contingency.tex
echo '\Blindtext[3] ' >> day3_contingency.tex
cat contingency_tableBEFws.tex >> day3_contingency.tex
cat contingency_tableBEFwd.tex >> day3_contingency.tex
cat contingency_tableBEFrh.tex >> day3_contingency.tex
cat contingency_tableBEFpwv.tex >> day3_contingency.tex
echo '\clearpage' >> day3_contingency.tex
cp day3_contingency.tex $WRKDIR/
# PODs TABLES
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > day3_PODs.tex
echo '\subsection{Title for PODs tables of Day 3}' >> day3_PODs.tex
echo '\Blindtext[3] ' >> day3_PODs.tex
cat tablePODsws.tex tablePODswd.tex \
    tablePODsrh.tex tablePODspwv.tex >> day3_PODs.tex
cp day3_PODs.tex $WRKDIR/
##################################################################################

##################################################################################
cp $textLOGs_file $WRKDIR
# TEMPLATE
# Check and modify the template Latex file
if [ ! -e $main_tmpl_file ]; then
  error "$main_tmpl_file doe not exist"
fi
export LC_TIME="en_US.UTF-8"
cat $main_tmpl_file | sed -e "s!TODAYDATESTRING!$TODAYDATESTRING!"    | \
                      sed -e "s!TODAYMONTHSTRING!$TODAYMONTHSTRING!"  | \
                      sed -e "s!TODAYYEARSTRING!$TODAYYEARSTRING!"    | \
                      sed -e "s!LASTMONTHSTRING!$LASTMONTHSTRING!"    | \
                      sed -e "s!LASTYEARSTRING!$LASTYEARSTRING!"    > $WRKDIR/main.tex
if [ $? != 0 ]; then
  error "Problem in creating $WRKDIR/main.tex file"
fi
if [ ! -f "$WRKDIR/main.tex" ]; then
  error "Cannot create $WRKDIR/main.tex. Exiting..."
fi

#Annex
if [ ! -e $annex_tmpl_file ]; then
  error "$annex_tmpl_file doe not exist"
fi
export LC_TIME="en_US.UTF-8"
cat $annex_tmpl_file | sed -e "s!TODAYDATESTRING!$TODAYDATESTRING!"    | \
                      sed -e "s!TODAYMONTHSTRING!$TODAYMONTHSTRING!"  | \
                      sed -e "s!TODAYYEARSTRING!$TODAYYEARSTRING!"    | \
                      sed -e "s!LASTMONTHSTRING!$LASTMONTHSTRING!"    | \
                      sed -e "s!LASTYEARSTRING!$LASTYEARSTRING!"    > $WRKDIR/annex.tex
if [ $? != 0 ]; then
  error "Problem in creating $WRKDIR/annex.tex file"
fi
if [ ! -f "$WRKDIR/annex.tex" ]; then
  error "Cannot create $WRKDIR/annex.tex. Exiting..."
fi

#################################################################
# COMPILING THE LATEX FILE
cd $WRKDIR
notice "Compiling the MAIN REPORT file"
pdflatex main.tex > /dev/null 2>&1
pdflatex main.tex > /dev/null 2>&1
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
notice "Compiling the ANNEX file"
pdflatex annex.tex > /dev/null 2>&1
pdflatex annex.tex > /dev/null 2>&1
if [ $? != 0 ]; then
  error "Problem in compiling $WRKDIR/annex.tex file"
else
  cp annex.pdf $annex_pdf_file
  if [ $? == 0 ]; then
    notice "OK $annex_pdf_file"
  else
    error "Generic error in cp -v main.pdf $annex_pdf_file"
  fi
fi

#################################################################
# exit
notice "End of "`basename $0`
exit 0
#################################################################

