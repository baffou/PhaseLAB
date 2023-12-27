% Program to compute inSilico images of nanoparticles
% I compute here the noise amplitude as a function of the lambda and d

clear
close all

addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% Construction of the setup
ME=Medium(1.5,1.5);

lambda=600e-9;
OB=Objective(100,1.3,'Olympus');
CGcam=CGcamera('Zyla','F2');
CGcam.setDistance(0.8e-3);
MI=Microscope(OB,200,CGcam);

Nim=30;
MI.zo=0.5e-6;
Npx=900; % should be multiple of 3
system='NP';
%system='noise';
%system='Gaussian';
shotNoise=false;

IL=Illumination(lambda,ME);

%% Construction of the T/OPD image, of a nanoparticle in this example
switch system
    case 'NP'
        radius=50e-9;
        DI = Dipole('Au',radius);
        DI = DI.shine(IL);
        
        IM0=imaging(DI,IL,MI,Npx);
    case 'noise'
        IM0=ImageQLSI(ones(Npx),zeros(Npx),MI,IL);
    case 'Gaussian'
        Gampl = 100e-9; % Gaussian profile amplitude [m]
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
%IM0.pxSize0=IM0.pxSize*MI.M;
%% Creation of the inSilico Interfero

Itf = CGMinSilico(IM0,shotNoise=shotNoise,Nimages=Nim);


%% Definition of the crops

crop = repmat(FcropParameters,3,1);
Rcrop = Npx/(2*MI.CGcam.zeta);
beta = acos(3/5);
%(x,y,R,Nx,Ny,opt)
crop(1) = FcropParameters(Npx/2+1                   ,Npx/2+1                   ,Rcrop,Npx,Npx);
crop(2) = FcropParameters(Npx/2+1+2*Rcrop*cos(beta),Npx/2+1+2*Rcrop*sin(beta),Rcrop,Npx,Npx);
crop(3) = FcropParameters(Npx/2+1-2*Rcrop*sin(beta),Npx/2+1+2*Rcrop*cos(beta),Rcrop,Npx,Npx);

%% Postprocessing of the insilico data

IM = QLSIprocess(Itf,IL);
%IM = QLSIprocess(Itf,IL,'Fcrops',crop);
% IM = QLSIprocess(Itf,IL,'Fcrops',IM.crops);
IM=IM.level0("params",[1 1 10 10]);
IM.figure

%% comparison
figure
hold on
plot(IM0.OPD(end/2,:),'--')
plot(IM.OPD(end/2,:),'--')
legend({'theo','insilico'})


