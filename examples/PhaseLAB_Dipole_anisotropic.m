%% Nanophase Matlab package
% Most simple program to compute the image of a dipole

%% HEADING 
clear
addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%% BUILDING THE MEDIUM -- ME=Medium(n,nS);
ME=Medium(1.5,1.5);

%% CREATION OF A DIPOLE -- DI=Dipole(material,radius);
lambda = 530e-9; % wavelength
radius = 150e-9; % NP radius

obj = 2; % 1, 2, or 3

switch obj
    case 1
        % nanosphere
        DI = Dipole('Au',radius);

    case 2
        % anisotropic particle defined by a polarisability tensor
        DI = Dipole([-1.5 + 3.5*1i, 1.2 , -1.5 + 3.53*1i]*1e-21);

    case 3
        % nanosphere made of a birefringent material
        DI = Dipole([1.9 1.3 1.3].^2,radius);
end

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB = Objective(100,0.7,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
MI = Microscope(OB,180);

%% CREATION OF THE ILLUMINATION -- IL=Illumination(lambda,Medium,irradiance[,polar])
IL = Illumination(lambda,ME,1,[1 1i]);    

%% ILLUMINATION OF THE DIPOLE
DI = DI.shine(IL);

%% COMPUTATION OF THE IMAGES
IM = imaging(DI,IL,MI,240);

%%
IM.figure

