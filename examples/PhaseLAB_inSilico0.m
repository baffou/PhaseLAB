% Program to compute inSilico images of nanoparticles
% I compute here the noise amplitude as a function of the lambda and d

clear
close all

addpath(genpath('/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% Construction of the setup

lambda = 530e-9;
d = 0.5e-3;
Npx = 300;
n = 1.33;

ME = Medium(n);
OB = Objective(200,1.3,'Olympus');
CGcam = CGcamera('sC8-830');
MI = Microscope(OB,180,CGcam);
IL = Illumination(lambda,ME);

%%

MI.CGcam.setDistance(d);
MI.zo =0.5e-6;

radius=50e-9;
DI = Dipole('Au',radius);

DI = DI.shine(IL);


IM0 = imaging(DI,IL,MI,Npx);

%% Creation of the inSilico Interfero

Itf = CGMinSilico(IM0,shotNoise=1,Nimages=15,NAill=IL.NA);

%% Postprocessing of the insilico data

IM = QLSIprocess(Itf,IL,'resolution','low');


dynamicFigure("gb",IM);

