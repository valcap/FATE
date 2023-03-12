All data here was produced using the standard MNH model (non-OS18). This of course applies only to astroclimatic parameters.

Here are stored the TREATED AR, TELEMETRY and MNH data.
TREATED AR data is a continuos time evolution during the night buit by selecting only a specific hour in the future as predicted by the AR.

The base organizations starts from these 6 directories :
1GG
2GG
3GG
4GG
5GG
6GG

1GG means AR data obtained with 1 days of buffer of past nights
2GG means AR data obtained with 2 days of buffer of past nights
etc...

In each of the above directories there is another set of directories:
1H
2H
3H
4H
5H
6H

1H means night reconstructed by taking the first hour in the future (from present time).
2H means night reconstructed by taking the second hour in the future.
etc...
AR data forecasts were extended up to a maximum of 6 hours in the future.

In each of the above directories there are the following parameters, each organized in a different directory (self-explicative):
PWV_TREATED
RH_TREATED
SEE_TREATED
TAU_TREATED
TEMP_TREATED
WD_TREATED
WS_TREATED
ISO_TREATED
GLF_TREATED

In each directory there are the treated data organized in one file for each night.
e.g. 1H/PWV_TREATED/PWV_ARevol_1H_1GG_20190731.dat

The date corresponds to the J-1 convention (the start of the night at PARANAL)
Each file has 2 lines of header and 4 columns:
e.g.:

20190731
 Seconds  Measures(PWV-mm)  Meso-NH(PWV-mm)  FORECAST_AR(PWV-mm)
        3480   1.56225407       1.37427771       1.55661082
        3540   1.55899179       1.37084174       1.54685938
        3600   1.55822134       1.36646318       1.53719056
        3660   1.55693448       1.36081994       1.52729475

The first line is the J-1 date of the start of the night at paranal.
Seconds measure the time from the start of the MNH simulation (18:00 UT of J-1). The timestep is one minute
Measures is the telemetry data
Meso-NH is the MNH simulation
FORECAST_AR is the AR forecast recostructed with the logic explained before.
All data has already been passed by a 1-hour moving average as prescribed by the AR procedure.

The only exception is the WD data file, which has 7 columns:

 20190731
 Seconds  Measures(WD-m/s_VX)  Measures(WD-m/s_VY)  Meso-NH(WD-m/s_VX)  Meso-NH(WD-m/s_VY)  FORECAST_AR(WD-m/s_VX)  FORECAST_AR(WD-m/s_VY)
        3660 -0.189113572       12.5606804      -2.70379806       7.71536970     -0.318350136       12.6574354
        3720 -0.166806445       12.5590439      -2.83303452       7.81212425     -0.332383156       12.6095533
        3780 -0.172320306       12.5306396      -2.95988488       7.90511799     -0.337894320       12.5440741
        3840 -0.177030951       12.5516605      -3.08011627       7.99528456     -0.336443067       12.4493399
        3900 -0.155300185       12.6265993      -3.18627334       8.07913208     -0.348891914       12.3032026

Here data is reported for the VX and VY components of the wind speed, which are the real parameters that are forecasted by the AR. WD can be reconstructed from these two parameters.
For everything else the file is built the same as the others.



To get the best performance you must use the 1H data computed with 5GG buffer of nights. All other data is usefull to understand how the performance scales either with time in the future or with the buffer length.

#######
WARNING!!!!!!
If the Telemetry data is absent, there is a 9999.00000 value on the corresponding row
Check the Telemetry column when reading the data


