%% The simplest program to compute the image of a dipole

clear

%% BUILDING THE MEDIUM -- ME=Medium(n,nS);
ME = Medium(1.5,1.5);

%% CREATION OF THE ILLUMINATION -- IL=Illumination(lambda,Medium,irradiance[,polar])
lambda = 532e-9;
IL = Illumination(lambda,ME);

%% CREATION OF A DIPOLE -- DI=Dipole(material,radius);
radius = 50e-9;
DI = Dipole('Au',radius);

%DI=DI.moveBy('x',2e-6,'z',2e-6);


%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB = Objective(100,0.7,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
MI = Microscope(OB,180);

%% ILLUMINATION OF THE DIPOLE
DI = DI.shine(IL);
DI1 = DI + DI.moveBy('x',1e-6);
DI2 = DI.moveBy('x',-1e-6)+DI.moveBy('z',-1e-6)+DI.moveBy('x',1e-6);

%% COMPUTATION OF THE IMAGES
clc
IM = ImageEM(n=4);

IM(1) = imaging(DI,IL,MI,100);
IM(2) = imaging(DI,IL,MI,200);
IM(3) = imaging(DI1,IL,MI,200);
IM(4) = imaging(DI2,IL,MI,200);

%% display of the OPD images of the 4 systems
dynamicFigure("ph", IM(1), "ph", IM(2), "ph", IM(3), "ph", IM(4))
fullwidth

%% display of the OPD & T images of the 4 systems
dynamicFigure("ph", IM(1), "ph", IM(2), "ph", IM(3), "ph", IM(4), ...
    "bw", IM(1).T, "bw", IM(2).T, "bw", IM(3).T, "bw", IM(4).T, "nm",[2,4])
fullwidth

%% Navigate from one image to another using the left and right arrow keys
dynamicFigure("ph", IM)

%% Navigate from one image to another using the left and right arrow keys
dynamicFigure("ph", IM, "bw", {IM.T})

%%
IM.figure



