function [OPDsimu, Tsimu, IMout] = process_DRIMAPS(IM, shotNoise,opt)
arguments
    IM
    shotNoise
    opt.Nim = 1
end

EE0=IM.Einc.EE0;
I0=abs(EE0(1))^2+abs(EE0(2))^2;

fwc=IM.Microscope.CGcam.Camera.fullWellCapacity*opt.Nim;

if shotNoise
    noiseFunction = @poissrnd;
else
    noiseFunction = @identity;
end

E2 = abs( IM.Ex + sqrt(I0/2)).^2 +  abs( IM.Ey + sqrt(I0/2)).^2;
corr = (fwc/2)/(mean(E2(:)));
I = cell(4,1);
for ii = 1:4
    E2 = abs( IM.Ex + sqrt(I0/2)*exp(1i*(ii-1)*pi/2) ).^2 +  abs( IM.Ey + sqrt(I0/2)*exp(1i*(ii-1)*pi/2) ).^2;
    I{ii}=noiseFunction(E2*corr); % factor of 4 because sum intensities of obj and ref
end

 %mieux faire la balance des normalisations des différentes techniques pour
 %qu'elles soient comparables entre elles.


% figure
% for ii=1:4
%     subplot(2,2,ii)
%     imagegb(I{ii})
% end

Phi = atan2(I{2}-I{4},I{1}-I{3}); % order inversion because the phase is applied on Einc

% calculation of the intensity image (which I don't really understand, but it works
T = (I{1}+I{2}+I{3}+I{4})/2; % Intensity image of ref+signal images. Why a factor of 2 and not 4?
Tsimu = (T-fwc/2)/(fwc/2); % Removal of the intensity of the ref, and normalisation by the intensity of a signal illumination

Tsimu = I{1};

OPDsimu = Phi*IM.Illumination.lambda/2/pi;
IMout = ImageQLSI(IM);

%% processing of the intensity image







