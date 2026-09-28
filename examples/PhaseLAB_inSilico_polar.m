%% Simulate the use of a polarCam, including a MPA
clear

%% BUILDING THE MEDIUM -- ME=Medium(n,nS);
ME = Medium('water','glass');
OB = Objective(100,1.0,'Olympus');
lambda = 530e-9;

Cam = Camera('PHX050S-PC');
Grat = CrossGrating('Gamma',39e-6,'lambda0',lambda);
CGcam = CGcamera(Cam,Grat,1.06);
MI = Microscope(OB,200,CGcam);
CGcam.setDistance(0.40e-3);


%% CREATION OF A DIPOLE -- DI=Dipole(material,radius);

radius = 40e-9;
material = 'Au';
%material = 1.5;

DI0 = Dipole(material,radius);

morpho = 'corral';
%morpho = 'line';

switch morpho
    case 'corral'
        R0 = 3e-6;
        theta = 5;

        Nt = 360/theta;
        DI = repmat(Dipole(),Nt,1);
        for ii=1:Nt
            DI(ii) = DI0.moveTo('x', R0*cosd(theta*(ii-1)), 'y', R0*sind(theta*(ii-1)));
        end

    case 'line'
        period = 2.05*radius;
        Nt = 21;
        DI = repmat(Dipole(),Nt,1);
        for ii=1:Nt
            DI(ii) = DI0.moveTo('x', ii*period - floor(Nt/2)*period);
        end
end
DI.figure
%% CREATION OF THE ILLUMINATION -- IL=Illumination(lambda,Medium,irradiance[,polar])

IL(1) = Illumination(lambda,ME,1,[1  1i]); % LCP
IL(2) = Illumination(lambda,ME,1,[1 -1i]); % RCP

IM0 = ImageEM(2);
Itf = Interfero(2);

for il = 1:2
    %% ILLUMINATION OF THE DIPOLE
    DI = DI.shine(IL(il));

    %% COMPUTATION OF THE IMAGES
    IM0(il) = imaging(DI,IL(il),MI,540);

    %% in silico
    [Itf0, ~, EE] = CGMinSilico(IM0(il),"ShotNoise",0);
    EEp = EE.polarMask();
    Itf(il) = Interfero(EEp.E2,MI);
    Itf(il).Reference(EEp.Einc.E2)
end

%%
Itfmulti = Itf.splitPolars();
IMmulti = QLSIprocess(Itfmulti,IL);

%%
pIm = ImagePolar(IMmulti);
pIm.set_eLim(0.95)

%% from the theoretical images
IMexp0 = repmat(ImageQLSI(),2,4);
IMexp0(:,1) = ImageQLSI(IM0.Jones('P',0));
IMexp0(:,2) = ImageQLSI(IM0.Jones('P',45));
IMexp0(:,3) = ImageQLSI(IM0.Jones('P',90));
IMexp0(:,4) = ImageQLSI(IM0.Jones('P',135));

IMo = adjustPolarOffsets(IMexp0);
pIm0 = ImagePolar(IMo);
pIm0.set_eLim(0.95)

%%
pIm.figure
pIm0.figure


