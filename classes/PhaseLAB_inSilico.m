%clear
close all

addpath(genpath('/System/Volumes/Data/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_v2.0/'))
format long

%% Construction of the setup
ME = Medium(1.33);
IL = Illumination(600e-9,ME);

OB = Objective(100,1.0,'Olympus');
CGcam = CGcamera('Zyla','P4');
MI = Microscope(OB,180,CGcam);
MI.CGcam.distance0 = 0.8e-3;
MI.zo = 0;

%% Construction of the T/OPD image, of a nanoparticle in this example
radius = 100e-9;
DI = Dipole('Au',radius);
DI = DI.shine(IL);

IM0 = imaging(DI,IL,MI,200);

%% Creation of the inSilico Interfero
%Itf = CGMinSilico(IM0,'Nimages',100);
Itf = CGMinSilico(IM0,'shotNoise',0);

%% Postprocessing of the insilico data

%IM = QLSIprocess(Itf,IL);
IM = QLSIprocess(Itf,IL,'FourierCrop',IM.crops);
IM.figure

%% compare the two images
figure
subplot(2,2,1)
imagegb(IM0.T)
subplot(2,2,2)
imagegb(IM.T)
subplot(2,2,3)
imageph(IM0.OPD)
subplot(2,2,4)
imageph(IM.OPD)

figure
subplot(1,2,1)
hold on
plot(IM0.T((end-1)/2,:))
plot(IM.T((end-1)/2,:))
title('T')
legend({'model','inSilico'})
subplot(1,2,2)
hold on
plot(IM0.OPD((end-1)/2,:))
plot(IM.OPD((end-1)/2,:))
title('OPD')
legend({'model','inSilico'})

%%
DI.alphaMie
IM0.alpha_Image
IM.alpha_Image % Careful: wrong value for the real part because the OPD mean value is set to zero.

