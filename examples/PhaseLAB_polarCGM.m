addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

% in this version, I use the new GUI for multichannel

clear
%% PROCESS POLAR IMAGES
ME=Medium('water','glass');
OB=Objective(100,1.3,'Olympus');

Cam = Camera(6.9e-6/2,1,1);
Grat = CrossGrating('Gamma',39e-6);
CGcam=CGcamera(Cam,Grat,1.07);
MI=Microscope(OB,200,CGcam,'PhaseLIVE');
CGcam.setDistance(0.5e-3); % SHOULD CHANGE !!
lambda=488e-9;
IL=Illumination(lambda,ME);

%% IMPORT FILES

folder = "nanoRod_polarImages/";

Itf = importItfRef(folder,MI);

Itf.crop("Size",2048);

Itfmulti = Itf.splitPolars();

IMmulti = QLSIprocess(Itfmulti,IL);

IMmulti.figure2

%%
IMmulti2 = IMmulti.adjustPolarOffsets();

polarImages = IMmulti2.extractPolarImages();

% or directly

polarImages = IMmulti.CGMpolar();

%% display final figure
n=1;

figure,
subplot(2,2,1)
imagegb(polarImages(n).theta0)
set(gca,'Colormap',hsv)
title("\theta_0")
subplot(2,2,2)
imagegb(polarImages(n).phibar)
title("\bar\phi")
subplot(2,2,3)
imageph(polarImages(n).dphi)
title("\delta\phi")
subplot(2,2,4)
imagegb(polarImages(n).rgbImage)
colormap(gca,hsv)
fullscreen
