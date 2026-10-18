clear
%% definition of the setup

ME = Medium('air','glass');
OB = Objective(60,0.7,'Olympus');
Cam = Camera(3.45e-6,1,1);
Grat = CrossGrating('Gamma',39e-6);
CGcam = CGcamera(Cam,Grat,1.0615);
CGcam.setDistance(0.8e-3);
MI = Microscope(OB,200,CGcam,'PhaseLAB');

%% definition of the illumination
lambda = 565e-9;
IL_L = Illumination(lambda,ME,1,[1 1i 0]);
IL_R = Illumination(lambda,ME,1,[1 -1i 0]);


%% Import data
Ref = Interfero(2);
ItfR = Interfero( dlmread("polar/ITF_0001.txt"), MI);
ItfL = Interfero( dlmread("polar/ITF_0002.txt"), MI);
RefR = Interfero( dlmread("polar/REF_0001.txt"), MI);
RefL = Interfero( dlmread("polar/REF_0002.txt"), MI);
% assign the references
ItfR.Reference(RefR)
ItfL.Reference(RefL)

%% Demosaicing
ItfR4 = ItfR.splitPolars();
ItfL4 = ItfL.splitPolars();

%% QLSI process
IMR = QLSIprocess(ItfR4,IL_R,"definition","low");
IML = QLSIprocess(ItfL4,IL_L,"definition","low");
IMbig = [IML, IMR];
% display
IMbig.figure

%% background flattening
mask = ones(IML(1).Ny, IML(1).Nx);
mask(IML(1).T<0.95) = 0;
IMbig.flatten('Legendre','nmax',[4 4], 'mask',mask);

%% image normalizations
IMbig.level0('params',[10,110,10,110],'method','boundaryMedian')
IMbig.normT('params',[10,110,10,110],'method','boundaryMedian')

%% defining the ImageQLSIpolar objects
pImR = ImageQLSIpolar(IMR);
pImL = ImageQLSIpolar(IML);
% adjusting the colorscale for display
pImR.set_eLim(0.65)
pImL.set_eLim(0.65)

% change the orgin of theta (vertical, from (Oy))
pImR.setThetaShift(pi/2);
pImL.setThetaShift(pi/2);

% display
pImL.figure
pImR.figure

%% mean ellipse properties (over the masks)
thetaRm = meanDirection(pImR.thetaEllipse(mask));
thetaLm = meanDirection(pImL.thetaEllipse(mask));
eLm = mean(pImR.e(mask));
eRm = mean(pImL.e(mask));

%% Jones matrix computation
% 2 equivalent syntaxes to compute the Jones Matrix:
J = im2J(IML,IMR);
J = im2J(pImL,pImR);
displayJonesMatrix(J,"clim",{[0.8 1.02],[0 0.05],[0 0.05],[0.8 1.02]})

%% computation of to, te and phi averaged over the masks
T = J2T(J);

te = mean(T.t_e(mask));
to = mean(T.t_o(mask));
phi = mean(T.phi(mask));

n1 = ME.n0;
soList = 1i*(2*n1)./(2*pi./lambda).*(1-to(:));
seList = 1i*(2*n1)./(2*pi./lambda).*(1-te(:));

%% computation of to, te and phi averaged over the masks, with Schurr

[U,V] = J2Schur(J);
[Ts, Jlin] = Schur2T(U,V);
tes  = mean(Ts.t_e(mask));
tos  = mean(Ts.t_o(mask));
phis = mean(Ts.phi(mask));
sosList = 1i*(2*n1)./(2*pi./lambda).*(1-tos);
sesList = 1i*(2*n1)./(2*pi./lambda).*(1-tes);

% comparison
fprintf('\t Direct\t Schurr\n')
fprintf('to:\t%.4f\t%.4f\n',to,tos)
fprintf('te:\t%.4f\t%.4f\n',te,tes)
fprintf('phi:\t%.1f°\t%.1f°\n',phi*180/pi,phis*180/pi)

