%% IMPORTS
clear
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

folder = 'GeobColor';

%% Importaing straight away the red and green images from the interferograms

ItfR = importItfRef(folder,MI,"channel","R");
ItfG = importItfRef(folder,MI,"channel","G");

%% Images list

nList = cell(3,1); 
nList{1} = 1:7;  % ref
nList{2} = 8:11;  % bkg
nList{3} = 12:16;  % OPF-fluo

%% method 1/ Importing a remote selection, and defining the reference images

RefR = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"channel","R","selection",nList{1});
RefG = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"channel","G","selection",nList{1});
BkgR = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"channel","R","selection",nList{2});
BkgG = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"channel","G","selection",nList{2});
ItfR = importItfRef(folder,MI,"nickname",'geobSyto9',"remote",1,"channel","R","selection",(nList{3}(1):nList{end}(end)));
ItfG = importItfRef(folder,MI,"nickname",'geobSyto9',"nickname",'geobSyto9',"remote",1,"channel","G","selection",(nList{3}(1):nList{end}(end)));

%% method 2/ Importing the interferos as a whole,
% and separate the red and green afterwards with splitColors applied to Itf

Itf = importItfRef(folder,MI);
[ItfG0, ItfR0] = Itf.splitColors();

RefR = ItfR0(nList{1});
RefG = ItfG0(nList{1});
BkgR = ItfR0(nList{2});
BkgG = ItfG0(nList{2});
ItfR = ItfR0(nList{3}(1):nList{end}(end));
ItfG = ItfG0(nList{3}(1):nList{end}(end));

%% assignment of the proper references

RefRm = RefR.mean(); 
RefGm = RefG.mean(); 

ItfR.Reference(RefRm);
ItfG.Reference(RefGm);

ItfR.removeOffset(BkgR.mean());
ItfG.removeOffset(BkgG.mean());

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
figure, imagegb(IMR(1).OPD), colormap(Sepia)

dynamicFigure('fl',{IMG.T}, 'ph', {IMR.OPD})

