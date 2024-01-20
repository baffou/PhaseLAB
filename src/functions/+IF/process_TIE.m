function [OPDsimu, Tsimu,IMout] = process_TIE(IMs, zShift, shotNoise, opt)
% OPDsimu: simulated OPD
% Tsimu: simulated normalize intensity image
% IMout: possibly modified IM, e.g. cropped or binned
arguments
    IMs
    zShift
    shotNoise = false
    opt.Nim = 1
end

fwc=IMs(1).Microscope.CGcam.Camera.fullWellCapacity*opt.Nim;

corr = (fwc/2)/(max([IMs(1).T(:);IMs(2).T(:);IMs(3).T(:)])); % division by a factor of 1.7, because the local intensity can largely exceed the fwc for some masks

if shotNoise,noiseFunction = @poissrnd;
else,        noiseFunction = @identity;
end

Iu=noiseFunction(IMs(1).T*corr);
I0=noiseFunction(IMs(2).T*corr);
Id=noiseFunction(IMs(3).T*corr);


pxSize = IMs(1).Microscope.pxSize;
lambda = IMs(1).Illumination.lambda;
n = IMs(1).Illumination.nS;

k = 2*pi*n/lambda;

Nx = IMs(1).Nx;
Ny = IMs(1).Ny;

dzI = (Iu-Id)/(2*zShift);
[qx0, qy0] = meshgrid(1:Nx, 1:Ny);
qx = 2*pi/pxSize*(qx0-Nx/2-1)/Nx;
qy = 2*pi/pxSize*(qy0-Ny/2-1)/Ny;
qx(logical((qx==0).*(qy==0))) = Inf;
qy(logical((qx==0).*(qy==0))) = Inf;

q2 = qx.^2 + qy.^2;

Psi = ifft2(ifftshift(1./q2.*fftshift(fft2(k*dzI))));

[DPsix, DPsiy] = gradFFT(Psi/pxSize);
[Hx, ~] = gradFFT(DPsix./I0/pxSize);
[~, Hy] = gradFFT(DPsiy./I0/pxSize);

Ph_TIE = -ifft2(ifftshift(1./q2.*fftshift(fft2(Hx+Hy))));

OPDsimu = lambda/(2*pi)*Ph_TIE;
Tsimu = IMs(2).T;

if any(isnan(OPDsimu(:)))
    pause(1)
end

%% Theoretical images

avgPhiTheo = IMs(2).Ph;
avgTtheo = IMs(2).T;
IMout = ImageQLSI(avgTtheo,avgPhiTheo*lambda/(2*pi),IMs(1).Microscope,IMs(1).Illumination);



end

function [Dx, Dy] = gradFFT(Im)
[Nx, Ny] = size(Im);
[qx0, qy0] = meshgrid(1:Nx, 1:Ny);
qx = 2*pi*(qx0-Nx/2-1)/Nx;
qy = 2*pi*(qy0-Ny/2-1)/Ny;
qx(logical((qx==0).*(qy==0))) = Inf;
qy(logical((qx==0).*(qy==0))) = Inf;
Dx = -imag(ifft2(ifftshift(qx.*fftshift(fft2(Im)))));
Dy = -imag(ifft2(ifftshift(qy.*fftshift(fft2(Im)))));

end

