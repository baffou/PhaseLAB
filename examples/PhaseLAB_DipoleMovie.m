%% Nanophase Matlab package
% Most simple program to compute the image of a dipole

%% HEADING 
clear
addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

format long
%% BUILDING THE MEDIUM -- ME=Medium(n,nS);
ME=Medium(1.5,1.5);

%% CREATION OF THE ILLUMINATION -- IL=Illumination(lambda,Medium,irradiance[,polar])
lambda=532e-9;
IL=Illumination(lambda,ME);

%% CREATION OF A DIPOLE -- DI=Dipole(material,radius);
radius=75e-9;
DI= Dipole('Au',radius);

%DI2=DI1.moveBy('x',2e-6,'z',2e-6);
%DI=DI1+DI2;

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB=Objective(100,0.7,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
MI=Microscope(OB,180);

%% ILLUMINATION OF THE DIPOLE
DI=DI.shine(IL);
%DI=DI.moveBy('z',0.8e-6,'x',0.8e-6);

%% COMPUTATION OF THE IMAGES
clc
IM=ImageEM(n=50);
for io=1:50
    IM(io)=imaging(DI.moveTo('x',io*1e-7),IL,MI,200);
end

%%
clc
IM.figure



