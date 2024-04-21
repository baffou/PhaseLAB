% Program to compute inSilico images of nanoparticles
% I compute here the noise amplitude as a function of the lambda and d

clear
close all

addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% Construction of the setup
lambda=550e-9;      % reference wavelength to etch glass
eD=550e-9;
%z0=0.5e-3;         % distance between the grating and the camera sensor
camPxSize=6.5e-6;   % camera chip pixel size
Nim=50;             % Number of summed images
w=40000;            % full well capacity of the camera
Npx=1200;           % Desired final image size [px], must be multiple of 30
zoom0=1;            % Relay lens zoom
theta=acos(3/5);    % possible values to maintain periodicity: 0, acos(3/5)
ME=Medium(1.5,1.5); % ME.n is here the r.i. of the medium of the condensor, i.e. 1, a priori!
Mobj=100;
d=0.5e-3;
NAobj=1.;
NAill=0;
Gamma=39e-6;
shotNoise=true;
system='NP';
%system='noise';
%system='Gaussian';

%% assignments
OB=Objective(Mobj,NAobj,'Olympus');
CG=CrossGrating(Gamma=Gamma,lambda0=lambda);
Cam=Camera(camPxSize,Npx,Npx);
CGcam=CGcamera(Cam,CG,zoom0);
MI=Microscope(OB,180,CGcam);
MI.CGcam.setDistance(d);
IL=Illumination(lambda,ME);
IL.NA=NAill;

%% Construction of the T/OPD image, of a nanoparticle in this example
switch system
    case 'NP'
        radius=40e-9;
        DI0 = Dipole('Au',radius);
        DI=repmat(DI0,5,1);
        DI(2)=DI(1).moveBy('x',5e-6,'y',1e-6);
        DI(3)=DI(1).moveBy('x',3e-6,'y',3e-6);
        DI(4)=DI(1).moveBy('x',-4.5e-6,'y',6e-6);
        DI(5)=DI(1).moveBy('x',-2e-6,'y',-4.2e-6);
        DI = DI.shine(IL);
        
        IM0=imaging(DI,IL,MI,Npx);
        IM0=IM0.crop(Size=600);
        OPD=IM0.OPD;
    case 'noise'
        IM0=ImageQLSI(ones(Npx),zeros(Npx),MI,IL);
    case 'Gaussian'
        Gampl = 10e-9; % Gaussian profile amplitude [m]
        Gradius = Npx/10; % Gaussian profile radius [m]
        [X,Y] = meshgrid(1:Npx,1:Npx);
        X = X-mean(X(:));
        Y = Y-mean(Y(:));
        Gauss=exp(-(X.^2+Y.^2)/Gradius.^2);
        OPD = Gampl*Gauss; % (Fig 2f)
        T=1-0.1*Gauss;
        Pha = 2*pi/lambda*OPD;
        IM0=ImageQLSI(sqrt(T),OPD,MI,IL);
end

%% Creation of the inSilico Interfero
%Itf=CGMinSilico(IM0,,'shotNoise',1,'Nimages',100);
MI.CGcam.RL.mask=0;
%Itf=CGMinSilico(IM0,shotNoise=shotNoise,Nimages=30);
Itf=CGMinSilico(IM0,shotNoise=shotNoise,Nimages=Nim,NAill=IL.NA,cut=0);

%Itf=Itf.crop(604);


%% Postprocessing of the insilico data

% IM = QLSIprocess(Itf,IL,'method','CPM','definition','low');
 IM = QLSIprocess(Itf,IL);
%IM = QLSIprocess(Itf,IL,'Fcrops',crop,'definition','low');
% IM = QLSIprocess(Itf,IL,'Fcrops',IM.crops);
%
% IM=IM.phaseLevel0([1 1 200 200]);
IM.figure

%% comparison
figure
hold on
plot(OPD(end/2,:))
plot(IM.OPD(end/2,:),'--')
legend({'theo','insilico'})

%%
figure
fullwidth
subplot(1,3,1)
imagegb(Itf.Itf(1:100,1:100))
subplot(1,3,2)
histogram(Itf.Itf)

%%
folder = 'NPsIinSilico';
mkdir(folder)
writematrix(Itf.Itf,[folder '/interferogram.txt'],'Delimiter',' ')
writematrix(Itf.Ref.Itf,[folder '/interferogram_ref.txt'],'Delimiter',' ')
writematrix(IM.OPD,[folder '/OPD.txt'],'Delimiter',' ')
writematrix(IM.T,[folder '/T.txt'],'Delimiter',' ')
writematrix(IM0.OPD - mean(mean(IM0.OPD)),[folder '/OPD0.txt'],'Delimiter',' ')
writematrix(IM0.T,[folder '/T0.txt'],'Delimiter',' ')

