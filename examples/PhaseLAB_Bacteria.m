%% Heading
addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% Building of the medium -- ME=Medium(n,nS);
%ME=Medium(1.33,1.5);
ME=Medium(1.33,1.5);

%% Building of the microscope -- MI=Microscope(magnification,NA,ME)
OB=Objective(100,1.3);
MI=Microscope(OB);

%% Creation of the illumination -- IL=Illumination(lambda,irradiance,ME)
IL=Illumination(530e-9,ME,1e9);

%% Creation of a dipole -- NP=Nanoparticle(material,geometry,param1,param2);
radius=100e-9;
length=500e-9;
NP=Nanoparticle(1.5^2,'rod',[length radius], 30e-9);
NP.figure

%% Illumination of the dipole
NP=NP.shine(IL);

%% Computation of the images
%IM=imaging(NP,IL,MI);
IM=imaging(NP,IL,MI,100);

%% Image display
IM.figure()

%%

avg=mean(mean(IM.OPD(1:40,1:40)));
OPDo=IM.OPD-avg;

DryMassNume=sum(OPDo(:))*IM.pxSize^2

DryMassTheo=((length-2*radius)*pi*radius^2+4/3*pi*radius^3)*(1.5-1.33)

%with a=33,
% DryMassNume =2.195009527908688e-20
% DryMassTheo =1.851445270515584e-20

%with a=30,
% DryMassNume =2.209801146011796e-20
% DryMassTheo =1.851445270515584e-20


