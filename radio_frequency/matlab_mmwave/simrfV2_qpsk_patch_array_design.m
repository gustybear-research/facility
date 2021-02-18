%% Patch Antenna Design for 66 GHz Operation 
%
% Define global variables for antenna design.
%

F0 = 66e9;       % Operating Center Frequency
ps = physconst('lightspeed');
lambda = ps/F0;  % Wavelength

%% 
% Design the microstrip patch antenna to resonate at the operating
% frequency and shape the ground plane for array integration. The ground
% plane size defines the spacing between antenna elements. The patch
% antenna is tilted for integration in a vertical linear (sub) array. We
% visualize the antenna geometry.
%

p = design(patchMicrostrip, F0);
p.GroundPlaneLength = lambda; 
p.GroundPlaneWidth  = lambda; 
p.TiltAxis          = [[0 1 0]; [0 0 1]];
p.Tilt              = [-90; -180];
show(p);

%%
% Verify the antenna resonance frequency.
%

figure;
impedance(p,linspace(60e9,70e9,21));

%% 3D Pattern Computation for the Isolated (rotated) Element
%
% Compute and visualize the far-field radiation pattern of the isolated
% antenna. The isolated element pattern is used to compute the array 
% pattern using pattern superposition.
%

P_isolated = pattern(p, F0);
figure
pattern(p, F0);

%% Antenna 8x4 Rectangular Array Design
%
% Use the computed pattern in a Phased Array System Toolbox object.
% Define a custom antenna element with the designed pattern.
%

patchElement = phased.CustomAntennaElement;
patchElement.AzimuthAngles    = (-180:5:180);
patchElement.ElevationAngles  = (-90:5:90);
patchElement.MagnitudePattern = P_isolated;
patchElement.PhasePattern     = zeros(size(P_isolated));

%% 
% Design the phased array using pattern superposition of the 
% isolated element.
%

numElementsA = 8; % number antenna element in each subarray
numElementsS = 4; % number of subarrays in an array

%%
% For the subarray design vertically stack 8 patches. The spacing between
% elements is lambda/2 (will cause grating lobes). Use tapering to reduce
% the effects of grating lobes. We cannot use spacing <lambda/2 because
% that's the size of the ground plane for each patch. Moreover, a smaller
% spacing will introduce coupling in between the antenna elements.
%

subULA = phased.ULA('NumElements',numElementsA,                         ...
    'Element',patchElement,                                             ...
    'ElementSpacing',lambda/2,                                          ...
    'ArrayAxis','z', 'Taper', hamming(8));

%%
% Design the array by horizontally stacking 4 subarrays.
%

aURA = phased.ReplicatedSubarray('Subarray',subULA,                     ...
    'GridSize',[1 numElementsS],                                        ...
    'SubarraySteering','Phase',                                         ...
    'PhaseShifterFrequency', F0,                                        ...
    'GridSpacing', lambda/2);
viewArray(aURA,'ShowIndex','All')

%% Test 8x4 URA with Beam Steering 
%
% Test the array to verify the beam steering behaviour at different angles,
% and to anticipate the behaviour when adopting a hybrid beamforming
% strategy.
%
% First choose an arbitrary direction at which to perform beamforming.
%

azimuth = 20;
elevation = 30;
direction =  [azimuth; elevation];

%%
% The subarray weights are computed to make the ULA steer towards the 
% elevation direction. The weights are used to compute the phase shift that
% will be applied to the RF transmitters.
%

SV = phased.SteeringVector('SensorArray', subULA,                       ...
    'PropagationSpeed', ps,                                             ...
    'IncludeElementResponse',true);
wULA = step(SV, F0, direction);
PhaseShift = angle(wULA)*180/pi;

%%
% Compute the weights to steer the entire array. Again, we use tapering to
% reduce the effects of the grating lobes. The computed weights will be
% used to steer the subarrays towards the azimuth plane.
%

SV = phased.SteeringVector('SensorArray', aURA,                         ...
    'PropagationSpeed', ps,                                             ...
    'IncludeElementResponse',true);
w_sub = step(SV, F0, direction, direction);
w_sub = w_sub.*(hamming(4));

%% 
% Visualize 3D pattern of the URA steering towards the desired direction.
%

figure
pattern(aURA, F0,                                                       ...
    'PropagationSpeed', ps,                                             ...
    'Type', 'directivity',                                              ...
    'CoordinateSystem', 'polar',                                        ...
    'Weights', w_sub,                                                   ...
    'Steerangle', direction);

%% Subarray Design with Antenna Toolbox for Estimation of Coupling Effects
%
% Design the subarray with Antenna Toolbox to verify that we can use
% pattern superposition for the array simulation, and to estimate the
% coupling effects in between the antenna elements.
%

pa = design(patchMicrostrip, F0);
pa.GroundPlaneLength = lambda; 
pa.GroundPlaneWidth  = lambda; 

l = linearArray;
l.Element = pa;
l.NumElements = 8;
l.ElementSpacing = lambda/2;
l.Tilt = 90;
l.TiltAxis = [0 1 0];
show(l);

%% 
% Compute an accurate subarray pattern using a full wave method of moment.
% To save time, we load the precomputed pattern stored in a MAT file.
%

figure
load simrfV2_qpsk_subarray;
pattern(l, F0);

%% 
% Compare the computed 2D pattern from full-wave solution versus pattern
% superposition for an isolated element. Results are in agreement.
%

u = phased.ULA('NumElements',8,                                         ...
    'Element',patchElement,                                             ...
    'ElementSpacing',lambda/2,                                          ...
    'ArrayAxis','z');

figure
p1 = patternAzimuth(l, F0, 0);
F  = polarpattern(p1);
p2 = patternAzimuth(u, F0, 0);
add(F,p2)

figure
p1 = patternElevation(l, F0, 0);
F  = polarpattern(p1);
p2 = patternElevation(u, F0, 0);
add(F,p2)
F.MagnitudeLim = [-40 20];

%% Modeling Coupling Between Antenna Elements in a Subarray
%
% Compute subarray coupling effects using s-parameters.
%

% Spars = sparameters(l,linspace(60e9,70e9,21));

smithplot(Spars)

% save('sparams.mat','Spars')