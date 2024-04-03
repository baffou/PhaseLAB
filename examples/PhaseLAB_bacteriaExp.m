%% Example that import intensity and phase experiemental images.

%% HEADING 
clear
addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% BUILDING OF THE MEDIUM -- ME=Medium(n,nS);
ME=Medium('water','glass');

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB=Objective(60,1.3,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
%MI=Microscope(OB,180,'sC8-830','PhaseLIVE');
MI=Microscope(OB,180,'sC8-830','PhaseLIVE');

%% BUILDING OF THE ILLUMINATION -- IL=Illumination(lambda);
lambda=625e-9;
IL=Illumination(lambda,ME);

%% IMPORT THE IMAGES -- Images=importItfRef(folder,MI,nickname);
folder='GeobLongFilaments';

%[Im,Rf]=importItfRef(folder,MI,'remote',1,'selection',1/5);
[Im,Rf]=importItfRef(folder,MI,'remote',1);

%% INTERFEROGRAM PROCESSING -- Im.QLSIprocess(IL);
IMlow = Im.QLSIprocess(IL,'definition','low');  % low definition

%IMhigh=Im.QLSIprocess(IL);  % high definition

IMlow.figure
