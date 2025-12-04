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

%% Importinterferos

Itf = importItfRef(folder,MI,"nickname","geobSyto9");
Bkg = importItfRef(folder,MI,"nickname","geobSyto9Bkg");
Ref = importItfRef(folder,MI,"nickname","geobSyto9Ref");

Itf.Reference(Ref.mean())

Itf.removeOffset(Bkg.mean());

Itf.crop(Size=1200)

%%

Itfs = Itf.splitColors();

Itfsc = crosstalkCorrection(Itfs);

%%
Itfsc.clearFcrops
IMG=QLSIprocess(Itfsc(:,1),IL,"Tnormalisation",'subtraction');
IMR=QLSIprocess(Itfsc(:,2),IL);


dynamicFigure('fl',{IMG.T}, 'ph', {IMR.OPD})

%%

IM = [IMG, IMR];

IM.figure2

