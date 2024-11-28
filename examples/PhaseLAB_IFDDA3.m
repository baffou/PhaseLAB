addpath(genpath('/home/gb/Documents/MATLAB/PhaseLAB_Git/'))

% Contruction of the microscope
lambda = 550e-9;
IL = Illumination(lambda,ME);

ME = Medium(1.33,1.5);
OB = Objective(100,1.3,'Olympus');
CG = CrossGrating(Gamma=39e-6,lambda0=IL.lambda);
Cam = Camera(6.5e-6,1024,1024);
CGcam = CGcamera(Cam,CG,1);
MI = Microscope(OB,180,CGcam);
MI.CGcam.setDistance(0.56e-3);

%% construction of the nanoparticle
NS = ParticleIFDDA('cube',"Size",50e-9);

%% computation of the nanoparticle image
IM = NS.imaging(MI, IL);


bin = 1;
n_obj = 1.5;
IF.meshes.grapheneGenerator("shape","disc","D",4e-6,"nz",60, ...
    "pxSize",MI.pxSize/bin,"fileName",'graphene.dat',n=n_obj)
Obj = IFDDAobject('arbitrary',fileName='graphene.dat',n=n_obj);
Npx = 1024;




