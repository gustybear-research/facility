clc; clear all;
%%% Simulate the signal
t = (0:1000)';
fsignal = 0.01;
x = sin(2*pi*fsignal*t);
c = physconst('Lightspeed');
fc = 300e6;
incidentAngle = [45;0];
array = phased.ULA('NumElements',7);
x = collectPlaneWave(array,x,incidentAngle,fc,c);
noise = 0.1*(randn(size(x)) + 1j*randn(size(x)));
rx = x + noise;

figure(1)
viewArray(array)

%%% Set up phase-shift beamformers and beamform input data
beamformer = phased.PhaseShiftBeamformer('SensorArray',array,...
    'OperatingFrequency',fc,'PropagationSpeed',c,...
    'Direction',incidentAngle,'WeightsOutputPort',true);
[y,w] = beamformer(rx);

%%% Plot the original signal at the middle element and the beamformed signal.
figure(2)
plot(t,real(rx(:,4)),'r:',t,real(y))
xlabel('Time (sec)')
ylabel('Amplitude')
legend('Input','Beamformed')

%%% Plot the array response pattern after applying the weights.
figure(3)
%pattern(array,fc,[-180:180],0,'PropagationSpeed',c,'Type',...
%    'directivity','CoordinateSystem','polar','Weights',w)
pattern(array, fc, 'Weights', w)
