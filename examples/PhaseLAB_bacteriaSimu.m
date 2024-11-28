%% Examples that simulate the CGM images of a bacterium and computes the dry mass

%% Building of the medium -- ME=Medium(n,nS);
ME = Medium(1.33,1.5);

%% Building of the microscope -- MI=Microscope(magnification,NA,ME)
OB = Objective(100,1.3);
MI = Microscope(OB);

%% Creation of the illumination -- IL=Illumination(lambda,irradiance,ME)
IL = Illumination(530e-9,ME,1e9);

%% Creation of a dipole -- NP=Nanoparticle(material,geometry,param1,param2);
radius = 100e-9;
length = 500e-9;
NP = Nanoparticle(1.5^2,'rod',[length radius], 30e-9);
NP.figure

%% Illumination of the dipole
NP = NP.shine(IL);

%% Computation of the images
IM = imaging(NP,IL,MI,100);

%% Image display
IM.figure()

%% dry mass estiations
% numerical
DryMassNume = sum(IM.OPD(:))*IM.pxSize^2;

% theoretical
DryMassTheo = ((length-2*radius)*pi*radius^2+4/3*pi*radius^3)*(1.5-1.33);

fprintf('Dry mass:\ntheo:\t%.2d\nsimu:\t%.2d\n', DryMassTheo, DryMassNume)



