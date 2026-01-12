#!/bin/bash

############################
# ATTENZIONE, PRIMA DI LANCIARE LA PROCEDURA
# RICORDARSI DI CAMBIARE
# LASTMONTHYEAR, LASTMONTHMONTH, LASTMONTHDAY
# in read_and_treat_DAYNIGHT_1.sh
# in read_and_treat_PERSISTENCE.sh
# e  read_and_treat_DAYNIGHT_23.sh

############################
# PREPROC NIGHT1 && DAY1
sh read_and_treat_DAYNIGHT_1.sh          2>&1 | tee log_read_and_treat_DAYNIGHT1.log

############################
# PERSISTENCE
sh read_and_treat_PERSISTENCE.sh         2>&1 | tee log_read_and_treat_PERSISTENCE.log

############################
# PREPROC NIGHT2,3 && DAY2,3
sh read_and_treat_DAYNIGHT_23.sh night 2 2>&1 | tee log_read_and_treat_NIGHT2.log
sh read_and_treat_DAYNIGHT_23.sh night 3 2>&1 | tee log_read_and_treat_NIGHT3.log 
sh read_and_treat_DAYNIGHT_23.sh day   2 2>&1 | tee log_read_and_treat_DAY2.log
sh read_and_treat_DAYNIGHT_23.sh day   3 2>&1 | tee log_read_and_treat_DAY3.log

############################
# EXIT
exit 0;
