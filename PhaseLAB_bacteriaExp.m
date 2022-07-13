%% Example that import intensity and phase experiemental images.

%% HEADING 
clear
addpath(genpath('/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

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
folder='/Volumes/NanoBio/_Maelle/Experimental data/20220204/exp1';

%[Im,Rf]=importItfRef(folder,MI,'remote',1,'selection',1/5);
[Im,Rf]=importItfRef(folder,MI,'remote',1,'selection',[1:100]);

%ImA=Im.mean();

%%
%Itf=imread('/Volumes/NanoBio/_Guillaume/LIVE/210923-neurons3/defaultAcquisitionName2_0001.tif');
%Ref=imread('/Volumes/NanoBio/_Guillaume/LIVE/210923-neurons3/REF_20210923_12h_18min_386sec.tif');
%Im=Interfero(Itf,MI);
%Im0=Interfero(Ref,MI);
%Im.Reference(Im0);

%% INTERFEROGRAM PROCESSING -- Im.QLSIprocess(IL);

IMlow=Im.QLSIprocess(IL,'Method','lowres');
%IMhigh=Im.QLSIprocess(IL);

IMlowf=IMlow.gauss(20);
%IM.phaseLevel0('manual')

IMlowf.figure

%% makeMoviedx(IM,videoName,rate,persp,phi,theta,ampl,zrange)
% with perspective
%makeMoviedx(IMlowf,'bacteria1.avi',5,1,45,45,1)
% without perspective
makeMoviedx(IMlowf,'bacteria2.avi',5,0,0,0,1)

