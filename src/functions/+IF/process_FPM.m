function [OPDsimu, Tsimu, IMout] = process_FPM(IM, shotNoise,opt)
arguments
    IM
    shotNoise
    opt.Nim = 1
end

P=repmat(PCmask(),4,1);
A = 1;
for ii=1:4
    P(ii)=PCmask(0,0.06,phi=(ii-1)*pi/2,A=A,type='disc');
end

IM_FPM=cell(4,1);
for ii=1:4 % somme sur les 4 déphasages SLIM
    IM_FPM{ii} = applyPCmask(IM,P(ii));
end

% definition of the darkfield mask (to get U1)
%P_DF = copy(P(1));
%P_DF.A=0;
%IM_DF = applyPCmask(IM,P_DF);

% definition of the brightfield mask (to get U0)
%P_BF = copy(P_DF);
%P_BF.inverted=true;
%IM_BF = applyPCmask(IM,P_BF);


if shotNoise
    noiseFunction = @poissrnd;
else
    noiseFunction = @identity;
end

EE0=IM.Einc.EE0;
I0=abs(EE0(1))^2+abs(EE0(2))^2;

fwc=IM.Microscope.CGcam.Camera.fullWellCapacity*opt.Nim;

corr = (fwc/2)/mean(IM_FPM{1}.E2(:));
I{1}=noiseFunction(IM_FPM{1}.E2*corr);
I{2}=noiseFunction(IM_FPM{2}.E2*corr);
I{3}=noiseFunction(IM_FPM{3}.E2*corr);
I{4}=noiseFunction(IM_FPM{4}.E2*corr);

%I_BF=noiseFunction(IM_BF.E2*fwc/(max(IM.E2(:))));
%I_DF=noiseFunction(IM_DF.E2*fwc/(max(IM.E2(:))));
%beta=sqrt(I_DF./I_BF);


%beta = sqrt(opt.A)*1/(4*fwc/1.7)*(I{1}-I{3}+I{2}-I{4})./(sin(DeltaPhi)+cos(DeltaPhi));

DeltaPhi = atan2(I{2}-I{4},I{1}-I{3}); % order inversion because the phase is applied on Einc

% calculation of beta according to ref 2004_Popescu_OL.pdf
beta = sqrt(A)*1/(4*fwc/2)*(I{1}-I{3}+I{2}-I{4})./(sin(DeltaPhi)+cos(DeltaPhi));

PHIsimu = atan2(beta.*sin(DeltaPhi),(1+beta.*cos(DeltaPhi)));

lambda=IM(1).Illumination.lambda;

OPDsimu=Unwrap_TIE_DCT_Iter(PHIsimu)*lambda/(2*pi);


% calculation of Tsimu
Tsimu = abs(1+beta.*exp(-1i*DeltaPhi)).^2;

IMout = ImageQLSI(IM);

% OPDtheo=angle(IM.Ey)*lambda/(2*pi);
% figure
% subplot(1,3,1)
% imagegb(OPDtheo)
% subplot(1,3,2)
% imagegb(OPDsimu)
% title('simu')
% title('theo')
% subplot(1,3,3)
% hold on
% plot(OPDtheo(end/2,:))
% plot(OPDsimu(end/2,:))
% fullscreen
% drawnow