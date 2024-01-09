function [OPDsimu, Tsimu, IMout] = process_SLIM(IMr, shotNoise,opt)
arguments
    IMr
    shotNoise
    opt.Nim = 1    % Number of averaged images
    opt.A   = 1  % transmission of the objective mask in intensity
end

Nphi = numel(IMr); % number of theta incidences involved in the calculations.
P=repmat(PCmask(),4,1);
for ii=1:4
    %    P(ii)=PCmask(0.3,0.02,phi=(ii-1)*pi/2,A=1,type='disc');
    P(ii)=PCmask(0,0.06,'phi',(ii-1)*pi/2,'A',opt.A);
end

P(1).setRadius(IMr(1));
P(2).setRadius(P(1));
P(3).setRadius(P(1));
P(4).setRadius(P(1));
%        P(2).figure(IMr)

% check the ring shape compare with the Fourier spots:
FTtot=0;
for io=1:Nphi
    FTtot=FTtot+IMr(io).FT;
end

%%
im1 = imgaussfilt(abs(FTtot),2);
im2 = angle(P(2).mask(IMr(1)));
im3 = FTtot*0+1;
figure
subplot(1,3,1)
imagegb(im1)
subplot(1,3,2)
imagegb(im2)
colormap(gca,Pradeep)
colorbar
clim([-pi pi]);
subplot(1,3,3)
imshow(cat(3,255*im1/max(im1(:)),255*im2/max(im2(:)),255*im3/max(im3(:))))
linkAxes
zoom(4)
fullscreen
drawnow

%%

Is=cell(4,1);  % sommation sur tous les angles d'illumination 1 à Nphi
for ii=1:4 % somme sur les 4 déphasages SLIM
    IM_SLIM = applyPCmask(IMr(1:Nphi),P(ii));
    Is{ii}=0;
    for jj = 1:Nphi
        Is{ii}=Is{ii}+IM_SLIM(jj).E2;
    end
    clear IM_SLIM
end

if shotNoise,noiseFunction = @poissrnd;
else,        noiseFunction = @identity;
end

EE0=IMr(1).Einc.EE0;
I0=abs(EE0(1))^2+abs(EE0(2))^2;
fwc=IMr(1).Microscope.CGcam.Camera.fullWellCapacity*opt.Nim;

% normalisation des images déphasées
% correction factor to apply to the raw intensity image Is to make them fit in
% the fwc of the camera. Is are initially around I0*Nim*opt.A is amplitude. One wants it
% fwc/1.7 in amplitude
corr = (fwc/2)/(median(Is{1}(:))); % division by a factor of 1.7, because the local intensity can largely exceed the fwc for some masks

I{1}=noiseFunction(Is{1}*corr);
I{2}=noiseFunction(Is{2}*corr);
I{3}=noiseFunction(Is{3}*corr);
I{4}=noiseFunction(Is{4}*corr);

%% affichage
% figure
% subplot(2,2,1)
% imagesc(I{1})
% colorbar
% axis image
% clim([0 3e4])
% subplot(2,2,2)
% imagesc(I{2})
% colorbar
% axis image
% clim([0 3e4])
% subplot(2,2,3)
% imagesc(I{3})
% colorbar
% axis image
% clim([0 3e4])
% subplot(2,2,4)
% imagesc(I{4})
% colorbar
% axis image
% clim([0 3e4])
% linkAxes

%%
DeltaPhi = atan2(I{2}-I{4},I{1}-I{3});
beta = sqrt(opt.A)*1/(4*fwc/2)*(I{1}-I{3}+I{2}-I{4})./(sin(DeltaPhi)+cos(DeltaPhi));
PHIsimu = atan2(beta.*sin(DeltaPhi),(1+beta.*cos(DeltaPhi)));
lambda=IMr(1).Illumination.lambda;
OPDsimu=Unwrap_TIE_DCT_Iter(PHIsimu)*lambda/(2*pi);
Tsimu = abs(1+beta.*exp(1i*DeltaPhi)).^2;

%% affichage
% figure
% subplot(2,2,1)
% imagesc(DeltaPhi)
% colorbar
% axis image
% title('DeltaPhi')
% subplot(2,2,2)
% imagesc((sin(DeltaPhi)+cos(DeltaPhi)))
% colorbar
% axis image
% title('sin(DeltaPhi)+cos(DeltaPhi)')
% subplot(2,2,3)
% imagesc((I{1}-I{3}+I{2}-I{4}))
% colorbar
% axis image
% title('I{1}-I{3}+I{2}-I{4}')
% subplot(2,2,4)
% imagesc(beta)
% colorbar
% axis image
% title('beta')
% clim([0 1.2])
% linkAxes
%% Theoretical images

avgPhiTheo = 0;
for ii=1:numel(IMr)
    avgPhiTheo = avgPhiTheo + IMr(ii).Ph/numel(IMr);
end
avgTtheo = 0;
for ii=1:numel(IMr)
    avgTtheo = avgTtheo + IMr(ii).T/numel(IMr);
end
IMout = ImageQLSI(avgTtheo,avgPhiTheo*lambda/(2*pi),IMr(1).Microscope,IMr(1).Illumination);




