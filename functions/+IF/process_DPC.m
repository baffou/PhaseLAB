function [OPDsimu, Tsimu, IMout] = process_DPC(IMq, shotNoise,opt)
arguments
    IMq (:,4) ImageEM
    shotNoise (1,1) logical = false
    opt.Nim = 1    % Number of averaged images
end

Nphi = size(IMq,1); % number of theta incidences involved in the calculations.
%
IM = ImageEM(n=4);
IM(1) = sum(IMq(:,1));
IM(2) = sum(IMq(:,2));
IM(3) = sum(IMq(:,3));
IM(4) = sum(IMq(:,4));

IMleft = IM(1)+IM(2);
IMright = IM(3)+IM(4);
%%
OPDsimu = (IMleft.T-IMright.T)./(IMleft.T+IMright.T);
Tsimu = IMleft.T+IMright.T;
%% Theoretical images
lambda=IMq(1).Illumination.lambda;
avgPhiTheo = 0;
for ii=1:numel(IMq)
    avgPhiTheo = avgPhiTheo + IMq(ii).Ph/numel(IMq);
end
avgTtheo = 0;
for ii=1:numel(IMq)
    avgTtheo = avgTtheo + IMq(ii).T/numel(IMq);
end
IMout = ImageQLSI(avgTtheo,avgPhiTheo*lambda/(2*pi),IMq(1).Microscope,IMq(1).Illumination);




