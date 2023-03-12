#!/bin/bash

function notice ( )
{
  echo `date +%H:%M:%S`" - "$@
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

