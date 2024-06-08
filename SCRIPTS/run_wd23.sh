#!/bin/bash

############################################################################
# Usage
############################################################################
if [ $# -ne 3 ]; then
  echo 'Not enough/too many arguments'
  echo "Usage: $0 env_file FCST_DAY FCST_LEN"
  echo "Example: $0 $HOME/SCRIPTS/fate-report.env [night || day] [1 || 2 || 3]"
  echo ""
  exit 1
else
  envfile=$1
  FCST_DAY=$2
  FCST_DAY_SHORT=`echo $FCST_DAY | cut -c1-3`
  FCST_LEN=$3
fi
#echo $envfile $FCST_DAY $FCST_DAY_SHORT $FCST_LEN

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

# Start
notice "Start of "`basename $0`

#########################################
## Working on wd
#
prefix='wd'
get_var_attr "$prefix"
# prefixUC
# descri
# unitof
# echo $suffix; exit
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

WRKDIR=$WRKDIR'/'${FCST_DAY}${FCST_LEN}

##################################################################################
##################################################################################
#                                   BEFORE 
##################################################################################
##################################################################################

#########################################
## Compute graphics and statistics
#
notice "Creating figures and calculating skills for BEFAFT $prefix ($descri)"
cd $PROG_ROOT_DIR
rm -f $WRKDIR/${skills_file}_BEFAFT_${prefix}

JOB=$prefix'_mnh_ar_hit_def_stan_45_45'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
IDELTA=10
FILE_LIST="list_"$prefixUC".txt"
if [ ! -e $FILE_LIST ]; then
  echo "ops $FILE_LIST is missing in the current directory"; exit 1
fi
NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
ROOT=$DATA_ROOT_DIR"/${prefixUC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
ROOT_WS=$DATA_ROOT_DIR"/WS_TREATED/"
if [ ! -d $ROOT_WS ]; then
  echo "ops $ROOT_WS is missing or is not a directory"; exit 1
fi
STARTIN="${prefixUC}_ARevol_"
STARTIN_WS="WS_ARevol_"
TAIL=".dat"
LIMIT=3.

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
${FCST_DAY_SHORT}${FCST_LEN}
${HH}
${IDELTA}
${NbNights}
${STARTMINUTE}
${ENDMINUTE}
${LIMIT}
"${ROOT}"
"${ROOT_WS}"
"${TAIL}"
"${STARTIN}"
"${STARTIN_WS}"
'$FILE_LIST'
'$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_stan.ps/cps'
'$FIGS_ROOT_DIR/pippo.ps/cps'
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
rm -f $FIGS_ROOT_DIR/pippo.ps

#
## End of computing graphics and statistics for BEFORE and AFTER data
#########################################

#########################################
# a file named ${skills_file}_BEFAFT_${prefix} is expected in $WRKDIR 
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
  rm -f $FIGS_ROOT_DIR/pippo.pdf
  ps2pdf $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.ps $FIGS_ROOT_DIR/pippo.pdf
  pdfcrop $FIGS_ROOT_DIR/pippo.pdf $FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.pdf  > /dev/null 2>&1
fi
rm -f $FIGS_ROOT_DIR/pippo.pdf
rm -f $FIGS_ROOT_DIR/pippo.pdf
mv $FIGS_ROOT_DIR/*.pdf $FIGS_ROOT_DIR/$FCST_DAY$FCST_LEN

#
##
#########################################

#########################################
## Compute statistics
## FOR LAST MONTH ONLY !!!!!!!!!!!!!!!!!
#
notice "Creating figures and calculating skills for BEFAFT $prefix ($descri) FOR LAST MONTH ONLY"
cd $PROG_ROOT_DIR
rm -f $WRKDIR/${skills_file}_BEFAFT_${prefix}_${skills_file_lastmonth}

JOB=$prefix'_mnh_ar_hit_def_stan_45_45'
if [ ! -e ${JOB}.f90 ]; then
  echo "ops ${JOB}.f90 is missing"; exit 1
fi
IDELTA=10
FILE_LIST="list_"$prefixUC"_${skills_file_lastmonth}.txt"
if [ ! -e $FILE_LIST ]; then
  echo "ops $FILE_LIST is missing in the current directory"; exit 1
fi
NbNights=`wc -l $FILE_LIST | cut -d ' ' -f 1`
ROOT=$DATA_ROOT_DIR"/${prefixUC}_TREATED/"
if [ ! -d $ROOT ]; then
  echo "ops $ROOT is missing or is not a directory"; exit 1
fi
ROOT_WS=$DATA_ROOT_DIR"/WS_TREATED/"
if [ ! -d $ROOT_WS ]; then
  echo "ops $ROOT_WS is missing or is not a directory"; exit 1
fi
STARTIN="${prefixUC}_ARevol_"
STARTIN_WS="WS_ARevol_"
TAIL=".dat"
LIMIT=3.

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
./${JOB}.exe<<EOF > $WRKDIR/${skills_file}_BEFAFT_${prefix}_${skills_file_lastmonth}
${FCST_DAY_SHORT}${FCST_LEN}
${HH}
${IDELTA}
${NbNights}
${STARTMINUTE}
${ENDMINUTE}
${LIMIT}
"${ROOT}"
"${ROOT_WS}"
"${TAIL}"
"${STARTIN}"
"${STARTIN_WS}"
'$FILE_LIST'
'$FIGS_ROOT_DIR/stoca1.ps/cps'
'$FIGS_ROOT_DIR/stoca2.ps/cps'
EOF
rm -f ${JOB}.exe
rm -f out_scatter_for_python_bef.dat out_scatter_for_python_aft.dat
rm -f $FIGS_ROOT_DIR/stoca1.ps $FIGS_ROOT_DIR/stoca2.ps

#
## End of computing statistics for BEFORE and AFTER data
#########################################

#########################################
## check a file named tmpfile_NAME-OF-THE-VARIABLE, which is expected in $PROG_ROOT_DIR
#
if [ ! -e $WRKDIR/${skills_file}_BEFAFT_${prefix}_${skills_file_lastmonth} ]; then
  error "$WRKDIR/${skills_file}_BEFAFT_${prefix}_${skills_file_lastmonth} not produced"
fi
#
##
#########################################

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
EPSBEF=$FIGS_ROOT_DIR/${FCST_DAY}${FCST_LEN}/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.pdf
cat << EOF > $WRKDIR/figures_${prefix}.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{figure}
\centering
\subfloat[]{\includegraphics[width=.33\linewidth,angle=0]{$EPSBEF}}
\caption{${FCST_DAY}${FCST_LEN} - $descri ($unitof): STANDARD CONFIGURATION}
\label{fig:$prefix:${FCST_DAY}${FCST_LEN}}
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
THRES1=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep THRES1 | awk '{print $3}'`
THRES2=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep THRES2 | awk '{print $3}'`
THRES3=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep THRES3 | awk '{print $3}'`
VAL1=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $5}'`
VAL2=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $6}'`
VAL3=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $7}'`
VAL4=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW1 | awk '{print $8}'`
VAL5=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $5}'`
VAL6=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $6}'`
VAL7=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $7}'`
VAL8=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW2 | awk '{print $8}'`
VAL9=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $5}'`
VAL10=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $6}'`
VAL11=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $7}'`
VAL12=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW3 | awk '{print $8}'`
VAL13=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW4 | awk '{print $5}'`
VAL14=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW4 | awk '{print $6}'`
VAL15=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW4 | awk '{print $7}'`
VAL16=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep ROW4 | awk '{print $8}'`
#SAMPSIZ=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep NbLines_TOT | awk '{print $3}'`
#SAMPSIZ=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep 'Hit rate computed on' | head -n 1`
SAMPSIZ=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep 'Number of points' | head -n 1`
POD1BEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD1 | awk '{print $5}'`
POD2BEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD2 | awk '{print $5}'`
POD3BEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD3 | awk '{print $5}'`
POD4BEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD4 | awk '{print $5}'`
PCBEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep PC | awk '{print $5}'`
EBDBEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep EBD | awk '{print $5}'`
my_nice_caption=${FCST_DAY}${FCST_LEN}' - Contingency table for {'$descri'} ('$unitof') in standard configuration'
cat << EOF >> $WRKDIR/contingency_tableBEF${prefix}.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{table}[p!]
\begin{center}
\begin{tabular}{llcccc}
\hline
{$descri}                                       &                             &    \multicolumn{4}{c}{Observations}                 \\\\
{$unitof}                                       &                             & {North}   & {East} & {South} & {West} \\\\
\hline
\multicolumn{1}{c}{\multirow{4}{*}{Model data}}  & {North}                    & $VAL1   & $VAL2    & $VAL3     & $VAL4\\\\
                                                 & {East}                     & $VAL5   & $VAL6    & $VAL7     & $VAL8\\\\
                                                 & {South}                    & $VAL9   & $VAL10   & $VAL11    & $VAL12\\\\
                                                 & {West}                     & $VAL13  & $VAL14   & $VAL15    & $VAL16\\\\
\hline 
\multicolumn{6}{l}{$SAMPSIZ PC=$PCBEF\\%; EBD=$EBDBEF\\%; POD1=$POD1BEF\\%; POD2=$POD2BEF\\%; POD3=$POD3BEF\\%; POD4=$POD4BEF\\%}                 \\\\
\end{tabular}
\end{center}
\caption{$my_nice_caption}
\label{tab:contingency${prefix}BEF:${FCST_DAY}${FCST_LEN}}
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
POD4BEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep POD4 | awk '{print $5}'`
PCBEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep PC | awk '{print $5}'`
EBDBEF=`cat $WRKDIR/${skills_file}_BEFAFT_${prefix} | grep LOGINFO | grep CONTTABLE | grep BEF | grep EBD | awk '{print $5}'`

my_caption=${FCST_DAY}${FCST_LEN}' - PODs for '$descri' ('$unitof')'
cat << EOF > $WRKDIR/tablePODs${prefix}.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{table}[p!]
\begin{center}
\begin{tabular}{|l|l|l|l|}
\hline
\multicolumn{1}{|c|}{\cellcolor[HTML]{C0C0C0}\textbf{PARAMETER}} & \multicolumn{1}{c|}{\cellcolor[HTML]{C0C0C0}\textbf{STANDARD}}\\\\
\hline
\cellcolor[HTML]{C0C0C0}POD1  & $POD1BEF      \\\\
\cellcolor[HTML]{C0C0C0}POD2  & $POD2BEF      \\\\
\cellcolor[HTML]{C0C0C0}POD3  & $POD3BEF      \\\\
\cellcolor[HTML]{C0C0C0}POD4  & $POD4BEF      \\\\
\cellcolor[HTML]{C0C0C0}PC    & $PCBEF        \\\\
\cellcolor[HTML]{C0C0C0}EBD   & $EBDBEF       \\\\
\hline
\end{tabular}
\caption{$my_caption}
\label{tab:pod${prefix}:${FCST_DAY}${FCST_LEN}}
\end{center}
\end{table}
EOF

####################################################
notice "End of "`basename $0`
exit 0
####################################################

