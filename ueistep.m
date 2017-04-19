function ueistep(n,f,ch,direction)
%UEISTEP Move stepper motor.
%   UEISTEP(N,F,CH,DIRECTION) commands a stepper motor connected to a
%   compatible drive to move N steps at a frequency of F Hz in the
%   specified direction. CH is a string used to select which channels to
%   use within a session. For example, the string '0:3' or '0,1,2,3'
%   selects digital output lines 0, 1, 2, and 3. DIRECTION is a logical
%   input where 0 is clockwise as viewed from the output shaft end and 1 is
%   counterclockwise. This input and others are sent to the drive by a UEI
%   DNx-DIO-403 layer installed in a PowerDNA Cube.
%
%   Compatible drives:
%   American Precision Industries P41/P42/P51 Series
%   Applied Motion Products PDO 2035
%   Applied Motion Products PDO 3540
%
%   Depending on what IP address the PowerDNA Cube is configured to use,
%   you may need to edit the IP address in this function.
%
%   This function is based on singledio_dotnet.m. See
%   C:\Program Files (x86)\UEI\Framework\DotNet\matlab_examples for other
%   examples.

%   Version 2017.04.19
%   Copyright 2017 Ryan McGowan

% Change these values depending on which lines the logical inputs are wired
% to on the DNx-DIO-403 layer
stepLine = 0;
directionLine = 1;
powerEnableLine = 2;

n_ch = length(eval(['[' ch ']']));

% Determine computer type and load appropriate UEIDAQ .NET assembly
c = computer;
switch c
    case 'PCWIN'
        NET.addAssembly('C:\Program Files\UEI\Framework\DotNet\UeiDaqDNet.dll');
    case 'PCWIN64'
        NET.addAssembly('C:\Program Files (x86)\UEI\Framework\DotNet\x64\UeiDaqDNet.dll');
end

import UeiDaq.*;

% Set up the digital output session
try
    % Digital output resource string
    doResourceStr = ['pdna://192.168.100.2/dev1/do' ch];
    
    % Create a session for digital output subsystem
    doSs = UeiDaq.Session();
    
    % Configure digital output session
    doSs.CreateDOChannel(doResourceStr);
    doSs.ConfigureTimingForSimpleIO();
    
    % Create a writer object
    doWriter = UeiDaq.DigitalWriter(doSs.GetDataStream());
    
    % Start session
    doSs.Start();
catch e
    e.message
    
    % Clean up the session
    doSs.Stop();
    doSs.Dispose();
    
    % Exit to prompt
    return
end

try
    % Generate pulse train
    doDataBi(stepLine+1) = 0;
    doDataBi(directionLine+1) = direction;
    doDataBi(powerEnableLine+1) = 0;
    for i = 1:n
        doDataBi(stepLine+1) = 0;
        doDataBi(directionLine+1) = direction;
        doDataBi(powerEnableLine+1) = 1;
        doData = bi2de(doDataBi)*ones(1,n_ch,'uint16');
        doWriter.WriteSingleScanUInt16(doData);
        pause(0.5*1/f);
        
        doDataBi(stepLine+1) = 1;
        doDataBi(directionLine+1) = direction;
        doDataBi(powerEnableLine+1) = 1;
        doData = bi2de(doDataBi)*ones(1,n_ch,'uint16');
        doWriter.WriteSingleScanUInt16(doData);
        pause(0.5*1/f);
    end
    
    % Set step to "Low", direction to "Low", power enable to "Low"
    doData = zeros(1,n_ch,'uint16');
    doWriter.WriteSingleScanUInt16(doData);
catch e
    e.message
end

% Clean up the session
doSs.Stop();
doSs.Dispose();
end

