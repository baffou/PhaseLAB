%% Example that import intensity and phase experiemental images.
addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% HEADING 
clear

%% BUILDING OF THE MEDIUM -- ME=Medium(n,nS);
ME=Medium('water','glass');

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB=Objective(100,0.7,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
MI=Microscope(OB,200,'sC8-944','PhaseLIVE');

%% BUILDING OF THE ILLUMINATION -- IL=Illumination(lambda);
%lambda=[500e-9 540e-9 580e-9 620e-9 660e-9 700e-9 740e-9];
lambda=531e-9;
IL=Illumination(lambda,ME);

%% IMPORT THE IMAGES -- Images=importItfRef(folder,MI,nickname);
folder='GeobLongFilaments';

Im =importItfRef(folder,MI,'remote',1);

%% INTERFEROGRAM PROCESSING -- m.QLSIprocess(IL);

IM=Im.QLSIprocess(IL);
IM.figure

%%
zList = -20:10;
No=length(zList);

IMlist=ImageQLSI(No);

for io = 1:No
    IMlist(io) = copy(IM(1));
    IMlist(io) = IMlist(io).propagation(zList(io)*1e-6);
     IMlist(io).comment = [num2str(zList(io)) ' µm'];
end
IMlist.level0(Center="Manual",Size="Manual");

IMlist.crop(Size=2000);

IMlist.overview("types",{'OPD'})

IMlist.makeMoviedx('/Users/perseus/Documents/im.avi', ...
    rate = 5, ...
    persp=0,theta=0, phi=0, ...
    zrange = [-80, 100])
