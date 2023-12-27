clear

addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

% In this program, I use CGMinSilico to actually model the transmission of
% the polarized field across the QLSI grating, with circularly polarized
% light

% PROCESS POLAR IMAGES
ME=Medium(1.5);
OB=Objective(100,1.0,'Olympus');

Cam = Camera(6.5,1200,1200);
Grat = CrossGrating('F2');
CGcam=CGcamera(Cam,Grat);
MI=Microscope(OB,400,CGcam,'PhaseLIVE');
CGcam.setDistance(0.86e-3); % SHOULD CHANGE !!
lambda=532e-9;
%CGcam.RL=RelayLens(1.1)
IL=Illumination(lambda,ME,1,[1 1i]);

%% Creates 4 QLSI images
radius = 1.5e-6;
Npx= Cam.Nx;
Np = 60;
dz = 0;
DI0 = Dipole('Au',40e-9);
DI = DI0.moveTo('x',radius);
for ii=1:Np-1
    DI = DI+DI0.moveTo('x',radius*cos(2*pi*ii/Np), ...
        'y',radius*sin(2*pi*ii/Np));
end
DI=DI.moveTo('z',dz);
DI=DI.shine(IL);
IMtheo=imaging(DI,IL,MI,Npx);

%% loop
angleList = 1:90;
Na = length(angleList);
Itf = Interfero(Na);

for ia = 1:Na
    Itf(ia).Microscope = duplicate(MI);
    Itf(ia).Microscope.CGcam.CGrotate(angleList(ia));
    Itf(ia)=CGMinSilico(IMtheo,'shotNoise',0,'method','rotation');
end
%%

IM = QLSIprocess(Itf,IL,"saveGradients",1,'resetCrops',true);
IM.figure


%%

dynamicFigure('ph',IM,'tf',Itf)


