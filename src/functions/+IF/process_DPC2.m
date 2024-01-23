function [OPDsimu, Tsimu, IMout] = process_DPC(IMq, NAi, shotNoise,opt)
arguments
    IMq (:,4) ImageEM
    NAi     % numerical aperture of the illumination
    shotNoise (1,1) logical = false
    opt.Nim = 1    % Number of averaged images
end

Nphi = size(IMq,1); % number of theta incidences involved in the calculations.
%

I1 = 0;
I2 = 0;
I3 = 0;
I4 = 0;
for ii = 1:4
    for ip = 1:Nphi
        I1 = I1 + IMq(ip,1).E2;
        I2 = I2 + IMq(ip,2).E2;
        I3 = I3 + IMq(ip,3).E2;
        I4 = I4 + IMq(ip,4).E2;
    end
end

Ileft = I1+I4;
Iright = I2+I3;
Itop = I1+I2;
Ibottom = I3+I4;
It = I1+I2+I3+I4;
%%
DWx = (Ileft-Iright)./It;
DWy = (Itop-Ibottom)./It;
x = (1:size(DWx,2))';
y = (1:size(DWx,1))';
Smatrix = g2sTikhonovRTalpha(x, y, 3);
OPDsimu = IMq(1,1).pxSize*NAi*g2sTikhonovRT(DWx, DWy, Smatrix, 1e-5);
Tsimu = Ileft+Iright;
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

% dynamicFigure('ph',OPDsimu,'ph',IMout.OPD),linkAxes
% figure, hold on, plot(36*OPDsimu(:,end/2+1)), plot(IMout.OPD(:,end/2+1)),legend({"simu","ground truth"})

