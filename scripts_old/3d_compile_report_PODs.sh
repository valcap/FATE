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
# PREPARE THE SECTION
cat << EOF > $WRKDIR/temporary_tablePODs.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
EOF

# Loop over variables
for prefix in ws rh pwv see tau glf
do
  get_var_attr $prefix
  
  #################################################################
  # Now ingest the outputs of the program by Elena
  # into the latex file

  ## PODs for BEF and AFT
  #
  cd $PROG_ROOT_DIR
  PROG=1
  # BEF
  POD1BEF=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD1 | awk '{print $5}'`
  POD2BEF=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD2 | awk '{print $5}'`
  POD3BEF=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD3 | awk '{print $5}'`
  PCBEF=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep PC | awk '{print $5}'`
  EBDBEF=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep EBD | awk '{print $5}'`
  # AFT
  POD1AFT=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep POD1 | awk '{print $5}'`
  POD2AFT=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep POD2 | awk '{print $5}'`
  POD3AFT=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep POD3 | awk '{print $5}'`
  PCAFT=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep PC | awk '{print $5}'`
  EBDAFT=`cat tmpfile_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep EBD | awk '{print $5}'`

  my_caption='PODs for '$descri' ('$unitof')'
cat << EOF > $WRKDIR/temporary_tablePODs${prefixUC}.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{table}[]
\begin{center}
\begin{tabular}{|l|l|l|l|}
\hline
\multicolumn{1}{|c|}{\cellcolor[HTML]{C0C0C0}\textbf{PARAMETER}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{STANDARD}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{WITH AR}} \\\\
\hline
\cellcolor[HTML]{C0C0C0}POD1  & $POD1BEF                                & $POD1AFT         \\\\
\cellcolor[HTML]{C0C0C0}POD2  & $POD2BEF                                & $POD2AFT         \\\\
\cellcolor[HTML]{C0C0C0}POD3  & $POD3BEF                                & $POD3AFT         \\\\
\cellcolor[HTML]{C0C0C0}PC    & $PCBEF                                  & $PCAFT           \\\\
\cellcolor[HTML]{C0C0C0}EBD   & $EBDBEF                                 & $EBDAFT          \\\\
\hline
\end{tabular}
\caption{$my_caption}
\end{center}
\end{table}
EOF

  cat $WRKDIR/temporary_tablePODs${prefixUC}.tex >> $WRKDIR/temporary_tablePODs.tex
  if [ $? != 0 ]; then
    echo  "+++ "`date +%c`" Problem in creating table file"; exit 1;
  fi
  if [ ! -f "$WRKDIR/temporary_tablePODs.tex" ]; then
    echo "Ops..big problem"
    echo "Cannot create $WRKDIR/temporary_tablePODs.tex. Exiting..."
    exit 1;
  fi
  rm -f $WRKDIR/temporary_tablePODs${prefixUC}.tex
done

#################################################################
notice "End of "`basename $0`
exit 0

