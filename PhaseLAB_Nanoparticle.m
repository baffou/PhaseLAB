%% Heading
addpath(genpath('/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% Building of the medium -- ME=Medium(n,nS);
%ME=Medium(1.33,1.5);
ME=Medium(1.33,1.5);

%% Building of the microscope -- MI=Microscope(magnification,NA,ME)
OB=Objective(100,1.3);
MI=Microscope(OB);

%% Creation of the illumination -- IL=Illumination(lambda,irradiance,ME)
IL=Illumination(530e-9,ME,1e9);

%% Creation of a dipole -- NP=Nanoparticle(material,geometry,param1,param2);
NP=Nanoparticle(1.5^2,'cuboid',[4000e-9 4000e-9 64e-9], 64e-9);
NP.figure

%% Illumination of the dipole
NP=NP.shine(IL);

%% Computation of the images
%IM=imaging(NP,IL,MI);
IM=imaging(NP,IL,MI,100);

%% Image display
IM.figure()





