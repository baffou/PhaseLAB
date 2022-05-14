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
MI=Microscope(OB,180,'sC8-830','PHAST');

%% BUILDING OF THE ILLUMINATION -- IL=Illumination(lambda);
lambda=625e-9;
IL=Illumination(lambda,ME);

%% IMPORT THE IMAGES -- Images=importItfRef(folder,MI,nickname);
folder='../Examples/200626-NeuronsLjiljana';
%[Im,Rf]=importItfRef(folder,MI,'selection',[1:25:650 651:674 675:25:1101]);
%[Im,Rf]=importItfRef(folder,MI,'remote',1,'selection',1/5);
%[Im,Rf]=importItfRef(folder,MI,'remote',0,'selection',[1 10 20 30 40]);
[Im,Rf]=importItfRef(folder,MI);
%Im =importItfRef(folder,MI,'remote',1,'selection',350:10:457);
%Im0=importItfRef(folder,MI,'remote',1,'selection',[800:850]);
%ImA=Im0.mean();

%%

%Itf=imread('/Volumes/NanoBio/_Guillaume/LIVE/210923-neurons3/defaultAcquisitionName2_0001.tif');
%Ref=imread('/Volumes/NanoBio/_Guillaume/LIVE/210923-neurons3/REF_20210923_12h_18min_386sec.tif');

%Im=Interfero(Itf,MI);
%Im0=Interfero(Ref,MI);
%Im.Reference(Im0);
%% INTERFEROGRAM PROCESSING -- Im.QLSIprocess(IL);



%IM=Im.QLSIprocess(IL,'intgrad2'); %if not square
%Im.Reference(ImA);

%IM=Im.QLSIprocess(IL,'Crop','manual');
IMhigh=Im.QLSIprocess(IL);
IMlow=Im.QLSIprocess(IL, method='CPM',resolution='low');
%IMf=IM.flatten(2);
%IM.phaseLevel0('manual')
%IMf.opendx(1,0,0)

figure
subplot(1,2,1)
imagegb(IMlow(1).OPD)
title('low res')
subplot(1,2,2)
imagegb(IMhigh(1).OPD)
title('high res')

%%
%imageph(IMf.OPD-imgaussfilt(IMf.OPD,50))
%%
IMs=IMhigh(1).OPD-imgaussfilt(IMhigh(1).OPD,120);
imageph(IMs)
%%
IM11s=IMhigh(11).smooth(2);
IM11s.opendx(1,0,0,1)

%%
Im2=copy(Im(2:end));
Im2.Reference(Im(1));
IM2=Im2.QLSIprocess(IL,'Crop','manual');
IM2.figure
%%

%makeMoviedx(IM2(1:10),'neurite1.avi',5,1,45,45,[0.8 1.2])
makeMoviedx(IMhigh,'neurite1.avi',5,1,45,45,1)

%%

Pha1217=dlmread('/Volumes/NanoBio/PARTAGE/ljiljana/210503_DryMass/V4/V4/phase/PHA V9 001217.txt');

