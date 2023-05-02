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

# Start
notice "Start of "`basename $0`

#########################################
## Working on ws
#
prefix='ws'
get_var_attr "$prefix"
# prefixUC
# descri
# unitof
# suffix
#
##
#########################################

#########################################
## Check directories 
#
if [ ! -d $DATA_ROOT_DIR ]; then
  echo "ops $DATA_ROOT_DIR is missing or is not a directory"; exit 1
fi
if [ ! -d $FIGS_ROOT_DIR ]; then
  echo "ops $FIGS_ROOT_DIR is missing or is not a directory"; exit 1
fi
if [ ! -d $PROG_ROOT_DIR ]; then
  echo "ops $PROG_ROOT_DIR is missing or is not a directory"; exit 1
fi
#
## End of check directories
#########################################

##################################################################################
##################################################################################
#                                   BEFORE and AFTER data 
##################################################################################
##################################################################################

#########################################
## Compute graphics and statistics
#
notice "Creating figures and calculating skills for BEFAFT $prefix ($descri)"
cd $PROG_ROOT_DIR
rm -f $WRKDIR/${skills_file}_BEFAFT_${prefix}

JOB=$prefix'_mnh_ar_hit_def_stan'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
IDELTA=10
FILE_LIST="list_"$prefixUC"_${GG}.txt"
if [ ! -e $FILE_LIST ]; then
  echo "ops $FILE_LIST is missing in the current directory"; exit 1
fi
NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
ROOT=$DATA_ROOT_DIR"/${prefixUC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
STARTIN="${prefixUC}_ARevol_"
TAIL=".dat"
LIMIT=0.     # limite inferiore da usarsi quando si vuole studiare lo scattering plot di WS sopra una certa soglia.
             # Se si vuole considerare tutto il sample mettere LIMIT=0.
MAXWS=999.   # put 999. if one wants to consider the whole values without filtering
             # ATT: use the option 999 if you wish to calculate the contingency tables

rm -f ${JOB}.exe
test -f out_scatter_for_python_bef.dat && rm -f out_scatter_for_python_bef.dat
test -f out_scatter_for_python_aft.dat && rm -f out_scatter_for_python_aft.dat
# Compile f90 file
gfortran -Wall -fbounds-check -o ${JOB}.exe ${JOB}.f90 -I$NUMREC_DIR -I$LIBPERSO_DIR/mod -L$LIBPERSO_DIR -L$NUMREC_DIR -J$NUMREC_DIR -lpgplot -lpng -lz -lpers -lnumrec > /dev/null 2>&1
if [ ! -e ${JOB}.exe ]; then
  echo "ops problem in compiling ${JOB}.f90"; exit 1
fi

subnotice "Running F90 program"
# Run f90 file
./${JOB}.exe<<EOF > $WRKDIR/${skills_file}_BEFAFT_${prefix}
${GG}
${HH}
${IDELTA}
${NbNights}
${STARTMINUTE}
${ENDMINUTE}
${LIMIT}
"${ROOT}"
"${TAIL}"
"${STARTIN}"
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan.ps/cps'
'$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_stan.ps/cps'
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat

#
## End of computing graphics and statistics for BEFORE and AFTER data
#########################################

#########################################
## check a file named tmpfile_NAME-OF-THE-VARIABLE, which is expected in $PROG_ROOT_DIR
#
if [ ! -e $WRKDIR/${skills_file}_BEFAFT_${prefix} ]; then
  error "$WRKDIR/${skills_file}_BEFAFT_${prefix} not produced"
fi
#
##
#########################################

#########################################
## check .ps files (see naming below), which are expected in $FIGS_ROOT_DIR
#
if [ ! -e $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps ]; then
  error "ops $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps not produced"
else
  mv $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.eps
fi
if [ ! -e $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps ]; then
  error "ops $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps not produced"
else
  mv $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.ps $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.eps
fi
#
##
#########################################

##################################################################################
##################################################################################
#                                   PERSISTENCE data 
##################################################################################
##################################################################################

#########################################
## Compute graphics and statistics
#
notice "Creating figures and calculating skills for PERSISTENCE $prefix ($descri)"
cd $PERS_ROOT_DIR
rm -f $WRKDIR/${skills_file}_PER_${prefix} 

JOB=$prefix'_mnh_ar_hit_def_stan'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
IDELTA=10
FILE_LIST="list_"$prefixUC"_${GG}.txt"
if [ ! -e $FILE_LIST ]; then
  echo "ops $FILE_LIST is missing in "`pwd`; exit 1
fi
NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
ROOT=$DATA_PERS_DIR"/${prefixUC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
STARTIN="${prefixUC}_PERSIST_"
TAIL=".dat"
LIMIT=0.     # limite inferiore da usarsi quando si vuole studiare lo scattering plot di WS sopra una certa soglia.
             # Se si vuole considerare tutto il sample mettere LIMIT=0.
MAXWS=999.   # put 999. if one wants to consider the whole values without filtering
             # ATT: use the option 999 if you wish to calculate the contingency tables

rm -f ${JOB}.exe
test -f out_scatter_for_python_bef.dat && rm -f out_scatter_for_python_bef.dat
test -f out_scatter_for_python_aft.dat && rm -f out_scatter_for_python_aft.dat
# Compile f90 file
gfortran -Wall -fbounds-check -o ${JOB}.exe ${JOB}.f90 -I$NUMREC_DIR -I$LIBPERSO_DIR/mod -L$LIBPERSO_DIR -L$NUMREC_DIR -J$NUMREC_DIR -lpgplot -lpng -lz -lpers -lnumrec > /dev/null 2>&1
if [ ! -e ${JOB}.exe ]; then
  echo "ops problem in compiling ${JOB}.f90"; exit 1
fi

subnotice "Running F90 program"
# Run f90 file
./${JOB}.exe<<EOF > $WRKDIR/${skills_file}_PER_${prefix}
${GG}
${HH}
${IDELTA}
${NbNights}
${STARTMINUTE}
${ENDMINUTE}
${LIMIT}
"${ROOT}"
"${TAIL}"
"${STARTIN}"
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan_per.ps/cps'
'$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_stan_per.ps/cps'
FALSE
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
#
## End of computing graphics and statistics for PERSISTENCE data
#########################################

# check tmpfile file
# a file named tmpfile_NAME-OF-THE-VARIABLE is expected in $PROG_ROOT_DIR
if [ ! -e $WRKDIR/${skills_file}_PER_${prefix} ]; then
  error "$WRKDIR/${skills_file}_PER_${prefix} not produced"
fi
# check .ps files
# .ps files (see naming below) are also expected in $FIGS_ROOT_DIR
if [ ! -e $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}_per.ps ]; then
  error "ops $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}_per.ps not produced"
else
  mv $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}_per.ps $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}_per.eps
fi
  if [ ! -e $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.ps ]; then
  error "ops $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.ps not produced"
else
  mv $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.ps $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.eps
fi

##################################################################################
##################################################################################
#                                CREATE LATEX AND PDF FILES
##################################################################################
##################################################################################

#                         #########################################
#                                1. FIGURES
#                         #########################################

#########################################
## Start of figures 
#
notice "Creating latex file with figures"
EPSBEF=$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.eps
EPSAFT=$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.eps
EPSPER=$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.eps
cat << EOF > $WRKDIR/figures_${prefix}.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{figure}
\centering
\subfloat[]{\includegraphics[width=.33\linewidth,angle=-90]{$EPSBEF}}
\subfloat[]{\includegraphics[width=.33\linewidth,angle=-90]{$EPSAFT}}
\subfloat[]{\includegraphics[width=.33\linewidth,angle=-90]{$EPSPER}}
\caption{$descri ($unitof): (a) STANDARD CONFIGURATION, (b) WITH AR, (c) PERSISTENCE.}
\label{fig:$prefix}
\end{figure}
EOF
#
## End of figures 
#########################################

#                         #########################################
#                                2. CONTINGENCY TABLES
#                         #########################################

notice "Extracting skills and creating contingency tables contingency_tableBEF${prefix}.tex and contingency_tableAFT${prefix}.tex"
rm -f $WRKDIR/contingency_tableBEF${prefix}.tex
rm -f $WRKDIR/contingency_tableAFT${prefix}.tex

cd $WRKDIR

# BEFORE STUFF
PERC1=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep PERCENTILES | grep X33_ | awk '{print $4}'`
PERC2=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep PERCENTILES | grep X66_ | awk '{print $4}'`
VAL1=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $5}'`
VAL2=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $6}'`
VAL3=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $7}'`
VAL4=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $5}'`
VAL5=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $6}'`
VAL6=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $7}'`
VAL7=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $5}'`
VAL8=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $6}'`
VAL9=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $7}'`
my_nice_caption='Contingency table for variable '$descri' ('$unitof') in standard configuration (i.e. BEF)'
cat << EOF >> $WRKDIR/contingency_tableBEF${prefix}.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{table}[]
\begin{center}
\begin{tabular}{llccc}
\hline
{$descri}                                       &                                                    & \multicolumn{3}{c}{Observations}                 \\\\
{$unitof}                                       &                             & $prefix $<$ $PERC1   & $PERC1 $<$ $prefix $<$ $PERC2 & $prefix $>$ $PERC2 \\\\
\hline
\multicolumn{1}{c}{\multirow{3}{*}{Model data}}  & $prefix $<$ $PERC1             & $VAL1                & $VAL2                       & $VAL3              \\\\
                                                 & $PERC1  $<$ $prefix $<$ $PERC2 & $VAL4                & $VAL5                       & $VAL6              \\\\
                                                 & $prefix $>$ $PERC2             & $VAL7                & $VAL8                       & $VAL9              \\\\
\hline
\end{tabular}
\end{center}
\caption{$my_nice_caption}
\label{tab:contingency${prefix}BEF}
\end{table}
EOF

# AFTER STUFF
VAL1=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW1 | awk '{print $5}'`
VAL2=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW1 | awk '{print $6}'`
VAL3=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW1 | awk '{print $7}'`
VAL4=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW2 | awk '{print $5}'`
VAL5=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW2 | awk '{print $6}'`
VAL6=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW2 | awk '{print $7}'`
VAL7=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW3 | awk '{print $5}'`
VAL8=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW3 | awk '{print $6}'`
VAL9=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep ROW3 | awk '{print $7}'`
my_nice_caption='Contingency table for variable '$descri' ('$unitof') processed with AR (i.e. AFT)'
cat << EOF >> $WRKDIR/contingency_tableAFT${prefix}.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{table}[]
\begin{center}
\begin{tabular}{llccc}
\hline
{$descri}                                       &                                                    & \multicolumn{3}{c}{Observations}                 \\\\
{$unitof}                                       &                             & $prefix $<$ $PERC1   & $PERC1 $<$ $prefix $<$ $PERC2 & $prefix $>$ $PERC2 \\\\
\hline
\multicolumn{1}{c}{\multirow{3}{*}{Model data}}  & $prefix $<$ $PERC1             & $VAL1                & $VAL2                       & $VAL3              \\\\
                                                 & $PERC1  $<$ $prefix $<$ $PERC2 & $VAL4                & $VAL5                       & $VAL6              \\\\
                                                 & $prefix $>$ $PERC2             & $VAL7                & $VAL8                       & $VAL9              \\\\
\hline
\end{tabular}
\end{center}
\caption{$my_nice_caption}
\label{tab:contingency${prefix}AFT}
\end{table}
EOF


#                         #########################################
#                                3. PODs FROR EACH CLASS
#                         #########################################

notice "Extracting skills and creating PODs table tablePODs${prefix}.tex"
## PODs for BEF and AFT
#
# BEF
POD1BEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD1 | awk '{print $5}'`
POD2BEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD2 | awk '{print $5}'`
POD3BEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD3 | awk '{print $5}'`
PCBEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep PC | awk '{print $5}'`
EBDBEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep EBD | awk '{print $5}'`
# AFT
POD1AFT=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep POD1 | awk '{print $5}'`
POD2AFT=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep POD2 | awk '{print $5}'`
POD3AFT=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep POD3 | awk '{print $5}'`
PCAFT=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep PC | awk '{print $5}'`
EBDAFT=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep AFT | grep EBD | awk '{print $5}'`

my_caption='PODs for '$descri' ('$unitof')'
cat << EOF > $WRKDIR/tablePODs${prefix}.tex
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

####################################################
notice "End of "`basename $0`
exit 0
####################################################

