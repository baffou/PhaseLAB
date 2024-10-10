%% Example that import intensity and phase experimental images.

clear

%% BUILDING OF THE MEDIUM -- ME=Medium(n,nS);
ME = Medium('water','glass');

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB = Objective(60,1.3,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
MI = Microscope(OB,200,'sC8-830','PhaseLIVE');

%% BUILDING OF THE ILLUMINATION -- IL=Illumination(lambda);
lambda = 625e-9;
IL = Illumination(lambda,ME);

%% IMPORT THE IMAGES -- Images=importItfRef(folder,MI,nickname);
folder = 'all';
Im = importItfRef(folder,MI);
%Im = importItfRef(folder,MI,'remote',1);


%% INTERFEROGRAM PROCESSING -- Im.QLSIprocess(IL);
IM = Im.QLSIprocess(IL,"saveGradients",1);

%%
IMf = IM(4).flatten();
IMf.figure

%%
makeMoviedx(IM,'210924-neurons.avi',rate=5, ampl=3, zrange=[-30 300])

