%% Heading

clear
close all
addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% BUILDING OF THE MEDIUM -- ME=Medium(n,nS);
ME = Medium('water','glass');

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB = Objective(60,1.3,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
%MI = Microscope(OB,180,'sC8-830','PhaseLIVE');
MI = Microscope(OB,180,'sC8-944','PhaseLIVE');
MI.refl = false;
%% BUILDING OF THE ILLUMINATION -- IL=Illumination(lambda);
lambda = 550e-9;
IL = Illumination(lambda,ME);

%%
folder=pwd;
Im = importItfRef(folder,MI);

%% INTERFEROGRAM PROCESSING -- Im.QLSIprocess(IL);
IM = Im.QLSIprocess(IL,'definition','low');  % low definition

%% Creation of the microscope
clear Med
Med(1) = MediumT('BK7',  1e-3,'progressive');
Med(2) = MediumT('water',1e-3,'progressive');
%Med(3) = MediumT('water',0.01e-3,'progressive');

Med=mesher(Med,MI);


%%
clc

IM.crop();

%%
IMs = IM.smooth(10);
dynamicFigure('gb',IM(3).OPD,'gb',IMs(3).OPD)
%%


[IMT, GreenW, GreenT] = IMs.TMPprocess(Med);


%IMT = IMs.TMPprocess(Med, GreenFunction=GreenW, GreenT_z0=GreenT);


%%
IMT.crop()
%%
IMT.figureT
  
  