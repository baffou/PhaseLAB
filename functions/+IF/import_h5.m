function IM = import_h5(fileh5)

% close all
% clc
% clear
% addpath(genpath('/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

%namefileh5=input('Please give the name of an H5 file : ','s');
% folder = '/Users/gbaffou/Documents/_DATA_SIMULATIONS/190729-PhaseLAB';
% namefileh5 = 'IFDDAexample1.h5';

%fileh5 = [folder '/' namefileh5];

if ~exist(fileh5,'file')
    disp(fileh5)
    error('Data files do not exist!')
end

info=h5info(fileh5);

% import parameters
opts = IF.import_h5_options(fileh5);

opts.dxSize = opts.pxSize*opts.Mobj;

%IF.disp_h5(fileh5)

IL=Illumination(opts.lambda);

%dxSize=opts.xscale(2)-opts.xscale(1);
%pxSize=dxSize/opts.Mobj;

OB=Objective(opts.Mobj,opts.NA,'Olympus');
Cam=Camera(opts.dxSize,opts.nfft,opts.nfft);
f_TL=180;
MI=Microscope(OB,f_TL,Cam);

% import images

Nf = (numel(info.Groups(1).Datasets)-3)/14; % number of simulations
IM = ImageEM(n=Nf);

for nim = 1:Nf
    printLoop(nim,Nf)
    % import images

    Exreal=h5read(fileh5,strcat('/Image/Image+incident',IF.compose3(nim),'kz>0 field x component real part'));
    Eximag=h5read(fileh5,strcat('/Image/Image+incident',IF.compose3(nim),'kz>0 field x component imaginary part'));
    Eyreal=h5read(fileh5,strcat('/Image/Image+incident',IF.compose3(nim),'kz>0 field y component real part'));
    Eyimag=h5read(fileh5,strcat('/Image/Image+incident',IF.compose3(nim),'kz>0 field y component imaginary part'));
    Ezreal=h5read(fileh5,strcat('/Image/Image+incident',IF.compose3(nim),'kz>0 field z component real part'));
    Ezimag=h5read(fileh5,strcat('/Image/Image+incident',IF.compose3(nim),'kz>0 field z component imaginary part'));

    Ex=reshape(Exreal+1i*Eximag,opts.nfft,opts.nfft);
    Ey=reshape(Eyreal+1i*Eyimag,opts.nfft,opts.nfft);
    Ez=reshape(Ezreal+1i*Ezimag,opts.nfft,opts.nfft);


    Esxreal=h5read(fileh5,strcat('/Image/Image',IF.compose3(nim),'kz>0 field x component real part'));
    Esximag=h5read(fileh5,strcat('/Image/Image',IF.compose3(nim),'kz>0 field x component imaginary part'));
    Esyreal=h5read(fileh5,strcat('/Image/Image',IF.compose3(nim),'kz>0 field y component real part'));
    Esyimag=h5read(fileh5,strcat('/Image/Image',IF.compose3(nim),'kz>0 field y component imaginary part'));
    Eszreal=h5read(fileh5,strcat('/Image/Image',IF.compose3(nim),'kz>0 field z component real part'));
    Eszimag=h5read(fileh5,strcat('/Image/Image',IF.compose3(nim),'kz>0 field z component imaginary part'));

    Esx=reshape(Esxreal+1i*Esximag,opts.nfft,opts.nfft);
    Esy=reshape(Esyreal+1i*Esyimag,opts.nfft,opts.nfft);
    Esz=reshape(Eszreal+1i*Eszimag,opts.nfft,opts.nfft);

    IM(nim) = ImageEM(Ex, Ey, Ez, Ex-Esx, Ey-Esy, Ez-Esz);
    IM(nim).Illumination = IL;
    IM(nim).Microscope = MI;
    IM(nim).Einc.Illumination = IL;
    IM(nim).Einc.Microscope = MI;
end
