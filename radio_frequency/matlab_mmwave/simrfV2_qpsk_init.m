
function SimParams = simrfV2_qpsk_init
% Simulation parameters
%

%   Copyright 2018 The MathWorks, Inc.

SimParams.CarrierFreq = 6.6e10;
SimParams.BitRate = 7.68e6;
SimParams.SampleTime = 1/SimParams.BitRate;

SimParams.NumSymsPerFrame = 100;
SimParams.SamplesPerSymbol = 2;
SimParams.NumBitsPerFrame = SimParams.NumSymsPerFrame      *            ...
    SimParams.SamplesPerSymbol;

SimParams.BarkerCode = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1]';
SimParams.BarkerLength = length(SimParams.BarkerCode);
SimParams.NumMsgBits = 105;
SimParams.BernoulliFrameBits = SimParams.NumBitsPerFrame   -            ...
    2*SimParams.BarkerLength - SimParams.NumMsgBits;
SimParams.BernoulliSampleTime = SimParams.NumBitsPerFrame  /            ...
    (SimParams.BitRate*SimParams.BernoulliFrameBits);

SimParams.RCFilterSpan = 10;
SimParams.RxRCFilterDecimation = 2;
SimParams.RolloffFactor = .2;