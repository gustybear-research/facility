clc; clear all;

c = 3e8; %speed of light
antenna = phased.IsotropicAntennaElement('BackBaffled',true); %antenna type (limited)

%%% INPUT %%%
fc = 10e9;

%Add subRow, subColumn, replRow, replColumn

%%%%%%%%%%%%%%

%%% Create array
sub_array = phased.URA('Size',[2 3],'ElementSpacing',0.5*c/fc,'Element',antenna);
% viewArray(sub_array)
replarray = phased.ReplicatedSubarray('Subarray',sub_array,...
    'GridSize',[2, 2]);
viewArray(replarray)

%%% Plot radiation pattern at a given frequency.
figure(2);
pattern(replarray,fc,[-180:180],0,...
   'PropagationSpeed',physconst('LightSpeed'),...
    'Type','powerdb',...
    'Normalize',true,...
    'CoordinateSystem','polar')
pattern(replarray,fc)

%%% Polar plots
%refula = phased.ULA(N,0.5*c/fc,'Element',antenna);
%subplot(2,1,1), pattern(replarray,fc,-180:180,0,'Type','powerdb',...
%    'CoordinateSystem','rectangular','PropagationSpeed',c); 
%title('Subarrayed ULA Azimuth Cut'); axis([-90 90 -50 0]);
%subplot(2,1,2), pattern(refula,fc,-180:180,0,'Type','powerdb',...
%    'CoordinateSystem','rectangular','PropagationSpeed',c); 
%title('ULA Azimuth Cut'); axis([-90 90 -50 0]);

%%% Multibeam Test

