# ueistep

UEISTEP(N,F,CH,DIRECTION) commands a stepper motor connected to a compatible drive to move N steps at a frequency of F Hz in the specified direction. CH is a string used to select which channels to use within a session. For example, the string '0:3' or '0,1,2,3' selects digital output lines 0, 1, 2, and 3. DIRECTION is a logical input where 0 is clockwise as viewed from the output shaft end and 1 is counterclockwise. This input and others are sent to the drive by a UEI DNx-DIO-403 layer installed in a PowerDNA Cube.

Compatible drives:
American Precision Industries P41/P42/P51 Series
Applied Motion Products PDO 2035
Applied Motion Products PDO 3540

Depending on what IP address the PowerDNA Cube is configured to use, you may need to edit the IP address in this function.

This function is based on singledio_dotnet.m. See C:\Program Files (x86)\UEI\Framework\DotNet\matlab_examples for other examples.

Version 2017.04.19  
Copyright 2017 Ryan McGowan
