%% Example that import intensity and phase experiemental images.

%% HEADING 
clear
%addpath(genpath('/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))
addpath(genpath('/Users/perseus/Documents/Simulations/PhaseLAB_git'))

%% BUILDING OF THE MEDIUM -- ME=Medium(n,nS);
ME=Medium('water','glass');

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB=Objective(60,1.3,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
MI=Microscope(OB,200,'sC8-830','PhaseLIVE');

%% BUILDING OF THE ILLUMINATION -- IL=Illumination(lambda);
lambda=625e-9;
IL=Illumination(lambda,ME);

%% IMPORT THE IMAGES -- Images=importItfRef(folder,MI,nickname);
folder='examples/all';
Im =importItfRef(folder,MI);
%Im =importItfRef(folder,MI,'remote',1);


%% INTERFEROGRAM PROCESSING -- Im.QLSIprocess(IL);

%IM=Im.QLSIprocess(IL,'intgrad2'); %if not square
%Im.Reference(ImA);
%IM=Im.QLSIprocess(IL,'Crop','manual');
IM=Im.QLSIprocess(IL,"saveGradients",1);

% To make this line work, one has to induce artificial aberration on the DW
% image during the QLSIprocess.m (line 167)


%%
%Im2=copy(Im(2:end));
%Im2.Reference(Im(1));
%IM2=Im2.QLSIprocess(IL);
IMf=IM(4).flatten(4);
IMf.figure

%%
IMf=IM(4).flatten('Background',4);
IMf.figure

%%
IMf=IM(4).flatten('Chebyshev',4);
IMf.figure

%%
% (IM,videoName,rate,persp,phi,theta,ampl,zrange)
% makeMoviedx(IM2(1:10),'neurite1.avi',5,1,45,45,[0.8 1.2])
% IM(1).opendx(1,45,45,8,[-50 220])
makeMoviedx(IM,'210924-neurons.avi',rate=5, ampl=3, zrange=[-30 300])

%%

%Pha1217=dlmread('/Volumes/NanoBio/PARTAGE/ljiljana/210503_DryMass/V4/V4/phase/PHA V9 001217.txt');

