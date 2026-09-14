%% TRIGGER INIT

clear DAQ connection channels

%% CONNECTION SHUTTERS

connection.SHUTTER_PHASE = 'port0/line0';
connection.SHUTTER_FLUO  = 'port0/line1';
connection.TRIGGER_PHA   = 'port0/line4';
connection.TRIGGER_FLUO  = 'port0/line5';

%% DAQ INITIALIZATION

DAQ.daqObj = daq('ni');

% Analog output used to provide the hardware clock
[channels.CLOCK, iClock] = ...
    DAQ.daqObj.addoutput('Dev1','ao0','Voltage');

% Digital outputs
[channels.SHUTTER_PHASE, iShutterPha] = ...
    DAQ.daqObj.addoutput('Dev1',connection.SHUTTER_PHASE,'Digital');

[channels.SHUTTER_FLUO, iShutterFluo] = ...
    DAQ.daqObj.addoutput('Dev1',connection.SHUTTER_FLUO,'Digital');

[channels.CAM_PHASE, iCamPhase] = ...
    DAQ.daqObj.addoutput('Dev1',connection.TRIGGER_PHA,'Digital');

[channels.CAM_FLUO, iCamFluo] = ...
    DAQ.daqObj.addoutput('Dev1',connection.TRIGGER_FLUO,'Digital');

%% TIMING

tick = 0.5e-3;              % 0.5 ms per sample
DAQ.daqObj.Rate = 1/tick;   % 2 kHz

%% INITIAL STATE

nChannels = numel(DAQ.daqObj.Channels);

DAQ.voltageState = zeros(1,nChannels);

write(DAQ.daqObj,DAQ.voltageState);

%% TTL BUILDING BLOCK

ttl = [0; 1; 0];

%% BUILD OUTPUT SIGNAL

voltageState = zeros(length(ttl),nChannels);

% Phase shutter is voltage controlled:
% high = open, low = closed
voltageState(:,iShutterPha) = 1;

% TTL-controlled devices
voltageState(:,iShutterFluo) = ttl;
voltageState(:,iCamPhase)    = ttl;
voltageState(:,iCamFluo)     = ttl;

%% SEND SIGNAL

write(DAQ.daqObj,voltageState);