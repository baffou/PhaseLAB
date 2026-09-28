%% Example of the processing of 2-color interferograms

clear

%% BUILDING OF THE MEDIUM -- ME=Medium(n,nS);
ME=Medium('water','glass');

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB=Objective(60,0.7,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
%MI=Microscope(OB,180,'sC8-830','PhaseLIVE');
CGcam=CGcamera('Silios','P04',1.5);
MI=Microscope(OB,200,CGcam);
CGcam.setDistance(1e-3);

%% BUILDING OF THE ILLUMINATION -- IL=Illumination(lambda);
lambda=625e-9;
IL=Illumination(lambda,ME);

%% IMPORT THE IMAGES -- Images=importItfRef(folder,MI,nickname);
ImGreen=imread('colorCamera/imGreen_00000_raw.tiff');
ImGreen=Interfero(ImGreen,MI);
ImRed=imread('colorCamera/imRed_00000_raw.tiff');
ImRed=Interfero(ImRed,MI);

ImGreenRef=imread('colorCamera/imGreenRef_00000_raw.tiff');
ImGreenRef=Interfero(ImGreenRef,MI);
ImRedRef=imread('colorCamera/imRedRef_00000_raw.tiff');
ImRedRef=Interfero(ImRedRef,MI);

ImGreen.Reference(ImGreenRef);
ImRed.Reference(ImRedRef);

%%
figure
subplot(2,2,1)
imagebw(ImGreen.Itf)
title("Green illumination")
subplot(2,2,2)
imagebw(ImRed.Itf)
title("Red illumination")
subplot(2,2,3)
imagebw(ImGreenRef.Itf)
title("Green illumination – Ref")
subplot(2,2,4)
imagebw(ImRedRef.Itf)
title("Red illumination – Ref")
fullscreen
linkAxes
zoom(10)
zoom("on")

%% Demosaicing

[ImG,~] = splitColors(ImGreen);
[~,ImR] = splitColors(ImRed);

%% crops
[ImG,params]=ImG.crop("twoPoints",true);
ImR.crop("params",params);
close all
%% Interfero process
Itf = [ImG, ImR];
IM=Itf.QLSIprocess(IL);

