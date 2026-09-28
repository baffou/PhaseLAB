% Program to compute inSilico images including shot noise
% used in Optics Communications 521, 128577 (2022)

clear

%% Parameters of the setup
lambda = 550e-9;    % reference wavelength to etch glass
eD     = 550e-9;    % Etching depth of the grating
d      = 0.5e-3;    % distance between the grating and the camera sensor
camPxSize=6.5e-6;   % camera chip pixel size
Nim    = 50;        % Number of summed images
w      = 40000;     % full well capacity of the camera
Npx    = 1200;      % Desired final image size [px], must be multiple of 30
zoom0  = 1;         % Relay lens zoom
theta  = acos(3/5); % possible values to maintain periodicity: 0, acos(3/5)
ME     = Medium(1.5,1.5); % ME.n is here the r.i. of the medium of the condensor, i.e. 1, a priori!
Mobj   = 100;       % Objective magnification 
NAobj  = 1.;        % Objective NA
Gamma  = 39e-6;     % CG pitch
shotNoise = true;   % activate the shot noise or not 

%% system
system = 'NP';
%system='noise';
%system='Gaussian';

%% construction of the objects from the parameters
OB   = Objective(Mobj,NAobj,'Olympus');
CG   = CrossGrating(Gamma=Gamma,lambda0=lambda);
Cam  = Camera(camPxSize,Npx,Npx);
CGcam= CGcamera(Cam,CG,zoom0);
MI   = Microscope(OB,180,CGcam);
MI.CGcam.setDistance(d);
IL   = Illumination(lambda,ME);

%% Construction of the T/OPD images
switch system
    case 'NP'
        radius = 40e-9;
        DI0    = Dipole('Au',radius);
        DI     = repmat(DI0,5,1);
        DI(2)  = DI(1).moveBy('x',5e-6,'y',1e-6);
        DI(3)  = DI(1).moveBy('x',3e-6,'y',3e-6);
        DI(4)  = DI(1).moveBy('x',-4.5e-6,'y',6e-6);
        DI(5)  = DI(1).moveBy('x',-2e-6,'y',-4.2e-6);
        DI     = DI.shine(IL);
        
        IM0    = imaging(DI,IL,MI,Npx);
        IM0    = IM0.crop("Size",600,"Center",'Auto');
        OPD0    = IM0.OPD;
        T0    = IM0.T;
    case 'noise'
        IM0    = ImageQLSI(ones(Npx),zeros(Npx),MI,IL);
        OPD0    = IM0.OPD;
        T0    = IM0.T;
    case 'Gaussian'
        Gampl  = 10e-9; % Gaussian profile amplitude [m]
        Gradius= Npx/10; % Gaussian profile radius [m]
        [X,Y]  = meshgrid(1:Npx,1:Npx);
        X      = X-mean(X(:));
        Y      = Y-mean(Y(:));
        Gauss  = exp(-(X.^2+Y.^2)/Gradius.^2);
        OPD0    = Gampl*Gauss; % (Fig 2f)
        T0      = 1-0.1*Gauss;
        Pha    = 2*pi/lambda*OPD0;
        IM0    = ImageQLSI(sqrt(T0),OPD0,MI,IL);
end

%% Creation of the inSilico Interfero
Itf = CGMinSilico(IM0,'shotNoise',shotNoise,'Nimages',Nim);

%% Postprocessing of the insilico data
IM = QLSIprocess(Itf,IL);
IM.figure

%% comparison
figure
hold on
plot(OPD0(end/2,:))
plot(IM.OPD(end/2,:),'--')
legend({'theo','insilico'})

