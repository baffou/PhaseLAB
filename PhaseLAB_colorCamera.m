%% Example that import intensity and phase experiemental images.

%% HEADING 

clear
addpath(genpath('/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% BUILDING OF THE MEDIUM -- ME=Medium(n,nS);
ME=Medium('water','glass');

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB=Objective(60,0.7,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
%MI=Microscope(OB,180,'sC8-830','PhaseLIVE');
CGcam=CGcamera('Silios','P4',1.5);
MI=Microscope(OB,200,CGcam);
CGcam.setDistance(1e-3);

%% BUILDING OF THE ILLUMINATION -- IL=Illumination(lambda);
lambda=625e-9;
IL=Illumination(lambda,ME);

%% IMPORT THE IMAGES -- Images=importItfRef(folder,MI,nickname);
ImGreen=imread('imGreen_00000_raw.tiff');
ImGreen=Interfero(ImGreen,MI);
ImRed=imread('imRed_00000_raw.tiff');
ImRed=Interfero(ImRed,MI);

ImGreenRef=imread('examples/colorCamera/imGreenRef_00000_raw.tiff');
ImGreenRef=Interfero(ImGreenRef,MI);
ImRedRef=imread('examples/colorCamera/imRedRef_00000_raw.tiff');
ImRedRef=Interfero(ImRedRef,MI);

ImGreen.Reference(ImGreenRef);
ImRed.Reference(ImRedRef);

%% Extrapolation
[ImG,~]=splitColors(ImGreen);
[~,ImR]=splitColors(ImRed);

%% crops
[ImG,xy1,xy2]=ImG.crop("twoPoints",true);
ImR.crop("xy1",xy1,"xy2",xy2);
%% Interfero process

IMG=ImG.QLSIprocess(IL);
IMR=ImR.QLSIprocess(IL);

