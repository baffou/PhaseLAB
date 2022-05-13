%% Example that import intensity and phase experiemental images.

%% HEADING
clear
addpath(genpath('/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_v2.0'))

ME = Medium('water','glass');
IL = Illumination(625e-9,ME);

OB = Objective(40,0.7,'Olympus');
CGcam = CGcamera('Zyla','P4');
MI = Microscope(OB,200,CGcam);
MI.CGcam.distance0 = 1e-3;


