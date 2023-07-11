function [OPDsimu, Tsimu, IMout] = process_DHM(IM, opt)
% OPDsimu: simulated OPD
% Tsimu: simulated normalize intensity image
% IMout: croped theoretical IM

arguments
    IM
    opt.shotNoise = false
    opt.freq = 3
    opt.thetaGrating
    opt.Nim = 1
end

[XX,YY]=meshgrid(1:IM.Nx,1:IM.Ny);

EE0=IM.Einc.EE0;
I0=abs(EE0(1))^2+abs(EE0(2))^2;

V=XX*sind(opt.thetaGrating)+YY*cosd(opt.thetaGrating);

Ref=sqrt(I0)*exp(-1i*(2*pi*(V)/opt.freq)); % supposed to be polarized along y
Itf00=abs(IM.Ey+Ref).^2 + abs(IM.Ex).^2;

Itf0=apodization(Itf00,40);
%figure
%imagegb(Itf0)


if opt.shotNoise
    noiseFunction = @poissrnd;
else
    noiseFunction = @identity;
end

fwc=IM.Microscope.CGcam.Camera.fullWellCapacity*opt.Nim;
Itf_dhm=noiseFunction(Itf0*(fwc/2)/(mean(mean(Itf0))));

% processing of the interferogram
Fitf=fftshift(fft2(Itf_dhm));
%figure, imagegb(log(abs(Fitf)))

dx=round(IM.Nx*sind(opt.thetaGrating)/opt.freq);
dy=round(IM.Ny*cosd(opt.thetaGrating)/opt.freq);

r1=floor(IM.Nx/6);
[X0, Y0]=meshgrid(-IM.Nx/2:IM.Nx/2-1,-IM.Ny/2:IM.Ny/2-1);
R02=X0.*X0+Y0.*Y0;
mask0=R02<r1^2;
mask1=circshift(mask0,dx,2);
mask1=circshift(mask1,dy,1);

%figure,imagegb(abs(log(Fitf.*mask1)))

Fitfs=circshift(Fitf.*mask1,-dx,2);
Fitfs=circshift(Fitfs,-dy,1);

IMdhm0=angle(ifft2(ifftshift(Fitfs)));
nc=20;
IMdhm0u=Unwrap_TIE_DCT_Iter(IMdhm0(nc+1:IM.Ny-nc,nc+1:IM.Nx-nc));
IMdhm0u=IMdhm0u-mean(IMdhm0u(:));
% removing the tilt
[X0s, Y0s]=meshgrid(-IM.Nx/2+nc:IM.Nx/2-1-nc,-IM.Ny/2+nc:IM.Ny/2-1-nc);
Xn=X0s/sqrt(sum(X0s(:).*X0s(:)));
Yn=Y0s/sqrt(sum(Y0s(:).*Y0s(:)));

mx=sum(IMdhm0u(:).*Xn(:));
my=sum(IMdhm0u(:).*Yn(:));


PHIdhm=IMdhm0u-Xn*mx-Yn*my;

OPDdhm=PHIdhm*IM.Illumination.lambda/(2*pi);
OPDdhm=OPDdhm-median(OPDdhm(:));


OPDsimu=OPDdhm;

% Computation of the intensity image :
Tdhm0 = real(ifft2(ifftshift(Fitf.*mask0)));
Tdhm = (Tdhm0 - fwc/4)/(fwc/4);  % (Tdhm-Iref)/Iref

Tsimu=Tdhm(nc+1:IM.Ny-nc,nc+1:IM.Nx-nc);

IMout = IM.crop("Size",IM.Nx-2*nc);
