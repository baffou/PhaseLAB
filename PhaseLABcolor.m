%% IMPORTS
clear all
addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% MICROSCOPE
ME=Medium('water','glass');
OB=Objective(60,0.7,'Olympus');
Cam = Camera('Silios');
Gr = CrossGrating('Gamma',39e-6);
CGcam=CGcamera(Cam,Gr,1.1931);
MI=Microscope(OB,200,CGcam,'PhaseLIVE');

CGcam.setDistance(0.8e-3);

lambda=680e-9;
IL=Illumination(lambda,ME);

folder = [pwd '/examples/GeobColor'];

%% Importaing straight away the red and green images from the interferograms

ItfR = importItfRef(folder,MI,"color","R");
ItfG = importItfRef(folder,MI,"color","G");

%% Images list

nList = cell(3,1); 
nList{1} = 1:7;  % ref
nList{2} = 8:11;  % bkg
nList{3} = 12:16;  % OPF-fluo

%% method 1/ Importing a remote selection, and defining the reference images

RefR = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"color","R","selection",nList{1});
RefG = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"color","G","selection",nList{1});
BkgR = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"color","R","selection",nList{2});
BkgG = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"color","G","selection",nList{2});
ItfR = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"color","R","selection",(nList{3}(1):nList{end}(end)));
ItfG = importItfRef(folder,MI,"nickname",'geobSyto9',"nickname",'geobSyto9',"remote",1,"color","G","selection",(nList{3}(1):nList{end}(end)));

RefRm = RefR.mean(); 
RefGm = RefG.mean(); 

ItfR.Reference(RefRm);
ItfG.Reference(RefGm);

ItfR.backgroundCorrection(BkgR.mean());
ItfG.backgroundCorrection(BkgG.mean());


%% method 2/ Importing the interferos as a whole,
% and separate the red and green afterwards with splitColors applied to Itf

%Itf = importItfRef([pwd '/GeobSyto9x100'],MI);
%[ItfG2, ItfR2] = Itf.splitColors();


%% correcting for the crosstalk

[ItfGc, ItfRc] = crosstalkCorrection(ItfG, ItfR);


%% crops
[~,params] = ItfGc(1).crop("twoPoints",1);

ItfGcc = ItfGc.crop("params",params);
ItfRcc = ItfRc.crop("params",params);

%%
IMR=QLSIprocess(ItfRcc,IL);
IMG=QLSIprocess(ItfGcc,IL,"Tnormalisation",false);
IMG2=QLSIprocess(ItfGcc,IL,"Tnormalisation",'subtraction');


figure, imagegb(IMG(1).T), colormap(invertedGreen())
