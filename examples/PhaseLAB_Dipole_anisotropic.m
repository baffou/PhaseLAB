%% Example that creates different types of nanoparticles, and computes the images
clear

%% BUILDING THE MEDIUM -- ME=Medium(n,nS);
ME = Medium(1.5,1.5);

%% CREATION OF A DIPOLE -- DI=Dipole(material,radius);
lambda = 530e-9; % wavelength
radius = 150e-9; % NP radius

obj = 3; % 1, 2, or 3

switch obj
    case 1
        % nanosphere
        DI = Dipole('Au',radius);

    case 2
        % nanoparticle defined by a polarisability tensor 
        eps = [-1.5 + 3.5*1i, 1.2 , -1.5 + 3.53*1i]; % complex permittivity [eps_x, eps_y, eps_z]
        DI = Dipole(sqrt(eps)*1e-21);

    case 3
        % purely birefringent material
        n = [1.9 1.3 1.3]; % [n_x, n_y, n_z]
        DI = Dipole(n,radius);
end

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB = Objective(100,1.3,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
MI = Microscope(OB,180);

%% CREATION OF THE ILLUMINATION -- IL=Illumination(lambda,Medium,irradiance[,polar])
IL = Illumination(lambda,ME,1,[1 1i]);    

%% ILLUMINATION OF THE DIPOLE
DI = DI.shine(IL);

%% COMPUTATION OF THE MICROSCOPE IMAGE
IM = imaging(DI,IL,MI,240);
IM.crop("Size",120,"Center",'Auto')

%% DISPLAY
IM.figure

