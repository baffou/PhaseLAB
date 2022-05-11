function [Itf, Grating] = CGMinSilico2(Image,Grating,opt)
% Function that creates a simulated interferogram from a given T/OPD set of
% images, including the image noise
% For this purpose, it uses all the data of the Microscope object contained
% in the ImageMethods object.
% CGMinSilico(Image, 'Nimages'=Nim, 'Shotnoise'='on')

% in this second version, rotation of the image with imrotate

arguments
    Image ImageMethods
    Grating CGmatrix
    opt.Nimages (1,1) {mustBeInteger,mustBePositive} = 1
    opt.ShotNoise (1,:) char {mustBeMember(opt.ShotNoise,{'on','off'})} = 'on'
    opt.Grating char ='QLSI'
    opt.NAill double = 0
    opt.setI0 (1,:) char {mustBeMember(opt.setI0,{'max','mean'})} = 'max'
    opt.cut (1,1) double = 0
end

if strcmpi(opt.ShotNoise,'on')
    noiseFunction=@poissrnd;
else
    noiseFunction=@identity;
end


T=Image.T;
OPD=Image.OPD;
Pha=Image.Ph;

%% Parameters
MI=Image.Microscope;
Nim=double(opt.Nimages);

w = MI.CGcam.Camera.fullWellCapacity;        % full well capacity of the camera
[Ny,Nx] = size(OPD);        % Desired final image size [px], must be square
IL=Image.Illumination;
%% Definition of some parameters

%% construction of the interferograms (Itf & Ref) according to Fig 2.

% (Fig 2a) Build the unit cell :


Emodel = Grating;
Emodel.im = sqrt(T).*exp(1i*Pha);

EmodelRef = Grating;
EmodelRef.im = ones(Ny,Nx);

%Emodelb = Emodel.propagation(wl,-d0);% Backpropagation of the light from the camera chip
%Emodelb = Emodel.propagation2(MI,IL,dir='backward');% Backpropagation of the light from the camera chip
%Egrating = Grating.*Emodelb;
%EmodelRefb = EmodelRef.propagation(wl,-d0);
%EmodelRefb = EmodelRef.propagation2(MI,IL,dir='backward');
%ErefGrating = Grating.*EmodelRefb;

% (Fig 2e,g) Propagate the light after the unit cell:
%E    = Egrating.propagation(wl,d0);
%Eref = ErefGrating.propagation(wl,d0);
%E    = Egrating.propagation2(MI,IL,dir='forward');
%Eref = ErefGrating.propagation2(MI,IL,dir='forward');

E20    =    Emodel.BackForPropagation(Grating,MI,IL);% Backpropagation of the light from the camera chip
E2Ref0 = EmodelRef.BackForPropagation(Grating,MI,IL);% Backpropagation of the light from the camera chip

% (Fig 2h,i) compute the intensity images:
[E2,fac] = E20.setI0(w*Nim,mode=opt.setI0); % set the max counts of the interferogram
E2Ref = E2Ref0.timesC(fac);% Apply the same correction factor to the reference interferogram
% hfig=figure;
% subplot(1,2,1)
% E.figure(hfig)
% title(sprintf('Real part of E-field at the camera plane\n Interfero'))
% subplot(1,2,2)
% Eref.figure(hfig)
% title(sprintf('Real part of E-field at the camera plane\n Reference'))
% drawnow

cut = opt.cut;% =1 or 2. to make artificial crosses in the Fourier space and better
% match what is observed experimentally. Otherwise, set to 0.
% Note it reduces the image size from Npx to Npx-cut.

% Add the shoit noise on the interferograms:
Itf    = Interfero(noiseFunction(   E2.im(1+cut:end-cut,1+cut:end-cut)),MI);
ItfRef = Interfero(noiseFunction(E2Ref.im(1+cut:end-cut,1+cut:end-cut)),MI);
Itf.Reference(ItfRef);


% plot of the interferogram and its Fourier transform:
% figure
% subplot(1,2,1)
% imagebw(Itf.Itf)
% title('interferogram')
% subplot(1,2,2)
% imagetf(Itf.Ref.Itf)
% title('Fourier transform of the interferogram')
%

end