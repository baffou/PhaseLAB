% PhaseLAB_IFDDA.m
clc
clear

addpath(genpath('/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

folder = '/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB';
namefileh5 = 'IFDDAexample1.h5';

fileh5 = [folder '/' namefileh5];

% display the structure of the hdf5 file
IF.disp_h5(fileh5)

% import images from the hfd5 file
IM = IF.import_h5(fileh5);


%% calculation of the CGM images, one by one, for each illumination
% add a CG (add it automatically to all images because microscope handle:
IM(1).Microscope.CGcam.CG=CrossGrating(Gamma=IM(1).dxSize*6,lambda0=IM(1).Illumination.lambda);
IM(1).Microscope.CGcam.setDistance(1e-3);
Itf=CGMinSilico(IM,shotNoise='off');
IMis = QLSIprocess(Itf,IM(1).Illumination);

% display the images
n=4
figure
subplot(1,2,1)
imageph(IM(n).OPD)
subplot(1,2,2)
imageph(-IMis(n).OPD)

%% Calculation of the CGM image when all the interferograms are summed

%Itfsum=Itf(1)+Itf(2)+Itf(3)+Itf(4);
Itfsum=sum(Itf);

IMsum = QLSIprocess(Itfsum,IM(1).Illumination);

% display the images
figure
subplot(1,2,1)
imagegb(IMsum.T)
title('intensity')
set(gca,'ColorMap',gray)
subplot(1,2,2)
imageph(-IMsum.OPD)
title('OPD')

%% Phase contrast
P=PCmask(0.3,0.1,phi=pi/2,A=0.5);
P.setRadius(IM(1));

IMm = applyPCmask(IM,P);
IMm.figure
IM.figure

figure
subplot(1,2,1)
Ttotal=IM(1).T+IM(2).T+IM(3).T+IM(4).T;
imagegb(Ttotal)
subplot(1,2,2)
TtotalPC=IMm(1).T+IMm(2).T+IMm(3).T+IMm(4).T;
imagegb(TtotalPC)
colormap(gray)

%% SLIM (page 229, book Popescu)

Nim = 4; % number of theta incidences involved in the calculations.

P=repmat(PCmask(),4,1);

for ii=1:4
%    P(ii)=PCmask(0.3,0.02,phi=(ii-1)*pi/2,A=1,type='disc');
    P(ii)=PCmask(0.3,0.04,phi=(ii-1)*pi/2,A=1);
end

P(1).setRadius(IM(1));
P(2).setRadius(P(1));
P(3).setRadius(P(1));
P(4).setRadius(P(1));

% definition of the darkfield mask
P_DF = copy(P(1));
P_DF.A=0;

P(2).figure(IM)

IM_SLIM=cell(4,1);
I=cell(4,1);  % sommation sur tous les angles d'illumination 1 à Nim
for ii=1:4 % somme sur les 4 déphasages SLIM
    IM_SLIM{ii} = applyPCmask(IM(1:Nim),P(ii));
    I{ii}=0;
    for jj = 1:Nim
        I{ii}=I{ii}+IM_SLIM{ii}(jj).E2;
    end
end

IM_DF = applyPCmask(IM(1:Nim),P_DF);
I_DF=0;
for jj = 1:Nim
    I_DF=I_DF+IM_DF(jj).E2./IM(jj).Einc.E2;
end


figure
for ii=1:4
    subplot(2,2,ii)
    imagegb(I{ii})
end

DeltaPhi = atan2(I{4}-I{2},I{1}-I{3});

IMsca=IM(1:Nim).Escat;
figure
subplot(1,2,1)
imageph((IMsca(1).Ph+IMsca(2).Ph+IMsca(3).Ph+IMsca(4).Ph)/4)
subplot(1,2,2)
imageph(-DeltaPhi)


PHI = atan2(I_DFn.*sin(DeltaPhi),(1+I_DFn.*cos(DeltaPhi)));

avgPhi = (IM(1).Ph+IM(2).Ph+IM(3).Ph+IM(4).Ph)/4;
figure
subplot(1,2,1), imageph(avgPhi)
subplot(1,2,2), imageph(-PHI)

%% SLIM théorique
% sans anneau de phase, en jouant directement
% avec les champs incidents et diffusés 
clc
IMs=IM.Escat();

DPhi = IMs(1).Ph;
figure
imageph(DPhi)

% total field = 
atot = 1+exp(1i*DPhi);

a0 = exp(1i*DPhi);
a1 = exp(1i*(DPhi+pi/2));
a2 = exp(1i*(DPhi+pi));
a3 = exp(1i*(DPhi+3*pi/2));

figure
subplot(2,2,1), imageph(angle(a0))
subplot(2,2,2), imageph(angle(a1))
subplot(2,2,3), imageph(angle(a2))
subplot(2,2,4), imageph(angle(a3))


b0 = abs(1+a0).^2;
b1 = abs(1+a1).^2;
b2 = abs(1+a2).^2;
b3 = abs(1+a3).^2;

DPhi_estimated = atan2(b3-b1,b0-b2);


figure
subplot(1,2,1)
imageph(DPhi)
subplot(1,2,2)
imageph(DPhi_estimated)


Phi=angle(atot);

Phi_estimated = atan2(sin(DPhi_estimated),1+cos(DPhi_estimated));

figure
subplot(1,2,1)
imageph(Phi)
subplot(1,2,2)
imageph(Phi_estimated)

% it works !



