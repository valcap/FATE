#!/bin/bash

rm libpers.a -f
rm *.mod *.o -f
test -d mod || mkdir mod
rm mod/* -f

gfortran -Wall -c -fbounds-check mod_statistics.f90
gfortran -Wall -c -fbounds-check mod_statistics_wd.f90
gfortran -Wall -c -fbounds-check *.f90

mv *.mod mod/

ar crs libpers.a *.o

