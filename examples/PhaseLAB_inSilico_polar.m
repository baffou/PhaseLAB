%% Nanophase Matlab package
% Most simple program to compute the image of a dipole

% In this second version, I average the two circular polarizations
%% HEADING
clear
addpath(genpath('/Users/perseus/Documents/git/PhaseLAB/PhaseLAB_private'))

%% BUILDING THE MEDIUM -- ME=Medium(n,nS);
ME = Medium('water','glass');
OB = Objective(100,1.0,'Olympus');
lambda = 530e-9;

Cam = Camera('PHX050S-PC');
Grat = CrossGrating('Gamma',39e-6,'lambda0',lambda);
CGcam = CGcamera(Cam,Grat,1.06);
MI = Microscope(OB,200,CGcam,'PhaseLIVE');
CGcam.setDistance(0.80e-3); % SHOULD CHANGE !!


%% CREATION OF A DIPOLE -- DI=Dipole(material,radius);

radius = 50e-9;
material = 'Au';
%material = 2.5^2;
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

%% CREATION OF THE ILLUMINATION -- IL=Illumination(lambda,Medium,irradiance[,polar])

IL(1) = Illumination(lambda,ME,1,exp(-1i*pi/4)*[1  1i]);
IL(2) = Illumination(lambda,ME,1,exp(-1i*pi/4)*[1 -1i]);

IM0 = ImageEM(2);
Itf = Interfero(2);
Itfmulti = cell(2,1);
IMmulti = cell(2,1);
polarImages = cell(2,1);
polarImages0 = cell(2,1);
IMmulti0 = cell(2,1);

for il = 1:2
    %% ILLUMINATION OF THE DIPOLE
    DI = DI.shine(IL(il));
    %DI=DI.moveBy('z',0.8e-6,'x',0.8e-6);

    %% COMPUTATION OF THE IMAGES
    IM0(il) = imaging(DI,IL(il),MI,540);

    %%
    IM0(il).figure

    %% in silico
    [Itf0, ~, EE] = CGMinSilico(IM0(il),"ShotNoise",0);
    EEp = EE.polarMask();
    Itf(il) = Interfero(EEp.E2,MI);
    Itf(il).Reference(EEp.Einc.E2)

    %%
    Itfmulti{il} = Itf(il).splitPolars();
    IMmulti{il} = QLSIprocess(Itfmulti{il},IL(il));

    %%
    polarImages{il} = ImagePolar(IMmulti{il});

    %% from the theoretical images

    IMmulti0{il}(1) = ImageQLSI(IM0(il).Jones('P',0));
    IMmulti0{il}(2) = ImageQLSI(IM0(il).Jones('P',45));
    IMmulti0{il}(3) = ImageQLSI(IM0(il).Jones('P',90));
    IMmulti0{il}(4) = ImageQLSI(IM0(il).Jones('P',135));

    IMo{il} = adjustPolarOffsets(IMmulti0{il});
    polarImages0{il} = ImagePolar(IMo{il});


end

IMmean = ImageQLSI(4)';
for ii = 1:4
    IMmean(ii) = mean([IMo{1}(ii), IMo{2}(ii)]);
end

adjustPolarOffsets(IMmean);

polarImages0mean = ImagePolar(IMmean);

polarImages0mean.figure