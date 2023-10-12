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
    export descri='wind speed'
    export unitof='$m s^{-1}$'
    export suffix='stan'
    ;;
  wd)
    export prefixUC='WD'
    export descri='wind direction'
    export unitof='degree'
#    export suffix='stan_0_90'
    export suffix='stan'
    ;;
  rh)
    export prefixUC='RH'
    export descri='relative humidity'
    export unitof='percent'
    export suffix='stan'
    ;;
  pwv)
    export prefixUC='PWV'
    export descri='precipitable water vapor'
    export unitof='mm'
    export suffix='stan'
    ;;
  see)
    export prefixUC='SEE'
    export descri='total seeing'
    export unitof='arcsec'
    export suffix='os18_1000'
   ;;
  tau)
    export prefixUC='TAU'
    export descri='coeherence time'
    export unitof='ms'
    export suffix='os18_1000'
    ;;
  glf)
    export prefixUC='GLF'
    export descri='ground layer fraction'
    export unitof='dimensionless'
    export suffix='os18'
    ;;
  *) echo "Lo sai chi ti saluta?"
     exit 1
     ;;
  esac
}

