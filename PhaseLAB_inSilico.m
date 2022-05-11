% Program to compute inSilico images of nanoparticles
% I compute here the noise amplitude as a function of the lambda and d

clear
close all

addpath(genpath('/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_v3.0'))
format long

%% Construction of the setup
ME=Medium(1.33);

lambda=550e-9;
d=0.5e-3;
%lambdaList=500e-9;
%dList=2.5e-3;
I0=40000;
Nim=30;
eD=550e-9;
OB=Objective(100,1.0,'Olympus');
CG=CrossGrating(39e-6,eD);
CGcam=CGcamera('Zyla',CG);
CGcam.RL.zoom=1;
MI=Microscope(OB,180,CGcam);
MI.zo=0e-6;
Npx=300; % should be multiple of 3
system='Gaussian';
%system='noise';
%system='Gaussian';
w=40000;
shotNoise='off';

MI.CGcam.setDistance(d);
IL=Illumination(lambda,ME);
IL.NA=0.5;

%% Construction of the T/OPD image, of a nanoparticle in this example
switch system
    case 'NP'
        radius=100e-9;
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

%% Creation of the inSilico Interfero
%Itf=CGMinSilico(IM0,,'shotNoise',1,'Nimages',100);

%Itf=CGMinSilico(IM0,shotNoise=shotNoise,Nimages=30);
Itf=CGMinSilico(IM0,shotNoise=shotNoise,Nimages=Nim,NAill=IL.NA);


%% Definition of the crops

crop = repmat(FcropParameters,3,1);
Rcrop = Npx/(2*MI.CGcam.zeta);
beta = acos(3/5);
%(x,y,R,Nx,Ny,opt)
crop(1) = FcropParameters(Npx/2+1                   ,Npx/2+1                   ,Rcrop,Npx,Npx);
crop(2) = FcropParameters(Npx/2+1+2*Rcrop*cos(beta),Npx/2+1+2*Rcrop*sin(beta),Rcrop,Npx,Npx);
crop(3) = FcropParameters(Npx/2+1-2*Rcrop*sin(beta),Npx/2+1+2*Rcrop*cos(beta),Rcrop,Npx,Npx);

%% Postprocessing of the insilico data

% IM = QLSIprocess(Itf,IL);
IM = QLSIprocess(Itf,IL,'Fcrops',crop);
% IM = QLSIprocess(Itf,IL,'Fcrops',IM.crops);
IM=IM.phaseLevel0([1 1 10 10]);
IM.figure

%% comparison
figure
hold on
plot(OPD(end/2,:))
plot(IM.OPD(end/2,:),'--')
legend({'theo','insilico'})


