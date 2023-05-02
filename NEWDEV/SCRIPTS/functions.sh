#!/bin/bash

function notice ( )
{
  echo `date +%H:%M:%S`" * "$@
  return 0
}

function subnotice ( )
{
  echo `date +%H:%M:%S`" -- "$@
  return 0
}


function warning ( )
{
  echo `date +%H:%M:%S`" --- WARNING - "$@
  return 0
}

function error ( )
{
  echo `date +%H:%M:%S`" +++ ERROR - "$@
  echo `date +%H:%M:%S`" - "End
  exit 1
}

function get_var_attr ()
{
  case "$1" in
  ws)
    export prefixUC='WS'
    export descri='Wind speed'
    export unitof='$m s^{-1}$'
    export suffix='stan'
    ;;
  wd)
    export prefixUC='WD'
    export descri='Wind direction'
    export unitof='degree'
#    export suffix='stan_0_90'
    export suffix='stan'
    ;;
  rh)
    export prefixUC='RH'
    export descri='Relative humidity'
    export unitof='percent'
    export suffix='stan'
    ;;
  pwv)
    export prefixUC='PWV'
    export descri='Precipitable water vapor'
    export unitof='mm'
    export suffix='stan'
    ;;
  see)
    export prefixUC='SEE'
    export descri='Total seeing'
    export unitof='arcsec'
    export suffix='os18_1000'
   ;;
  tau)
    export prefixUC='TAU'
    export descri='Coeherence time'
    export unitof='ms'
    export suffix='os18_1000'
    ;;
  glf)
    export prefixUC='GLF'
    export descri='Ground layer fraction'
    export unitof='dimensionless'
    export suffix='os18'
    ;;
  *) echo "Lo sai chi ti saluta?"
     exit 1
     ;;
  esac
}

#########################################################################
function email_alert ()
{
  echo `date +%H:%M:%S`" - "$@
  TMPDIR='/home/lamma/scripts/campo_regata/makepdf'
  ERROR_TMPL=${TMPDIR}'/tmpl.email_alert.pl'

  toaddress='capecchi@lamma.rete.toscana.it'
  ccaddress='previsori@lamma.rete.toscana.it'
#  ccaddress='baudone@lamma.rete.toscana.it,gozzini@lamma.rete.toscana.it,brandini@lamma.rete.toscana.it,ortolani@lamma.rete.toscana.it,previsori@lamma.rete.toscana.it'
  subjecttext='ERROR in Automatic Giglio Weather Bullettin @ '`date +%c`
  emailtext=' Error message is: '$@'.\n\n This is an automatic email, do not reply to this email address and use the email addresses in CC.\n\n Regards from postmare (192.168.1.46)'
  
  if [ ! -f "$ERROR_TMPL" ]; then
    error "missing tmpl $ERROR_TMPL! Exiting..."
  fi
  res=`cat $ERROR_TMPL | sed -e "s/TOADDRESS/$toaddress/g" | \
                         sed -e "s/CCADDRESS/$ccaddress/g" | \
                         sed -e "s/SUBJECTTEXT/$subjecttext/g" | \
                         sed -e "s!EMAILTEXT!$emailtext!" > $TMPDIR/puppa.pl`
  res=`perl $TMPDIR/puppa.pl`
  rm -f $TMPDIR/puppa.pl
}

