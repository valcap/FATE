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
  # into the latex file

  ## Figures
  #
  cd $FIGS_ROOT_DIR
  PROG=1

  EPSBEF=$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_BEF_${suffix}.eps
  EPSAFT=$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}.eps
  EPSPER=$FIGS_ROOT_DIR/${prefix}_sim_mnh_ar_dimm_${STARTMINUTE}_${ENDMINUTE}_AFT_${suffix}_per.eps
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
\caption{$descri ($unitof): (a) STANDARD, (b) WITH AR, (c) PERSISTENCE.}
\label{fig:$prefix}
\end{figure}
EOF
done
########################################################################

#################################################################
notice "End of "`basename $0`
exit 0

