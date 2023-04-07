function Mz=improp(M,period,lambda,z,dx,dy)
% Function that propagates a light beam over a distance z, assuming the
% image is periodic in x and y, with a period period.
% period: size of the image [m]
% lambda: light wavelength
% dx and dy shift the phase of the image by dx and dy pixels (not necessarily integers)

if nargin==4
    dx=0;
    dy=0;
end

dxSize=period/size(M,2); % camera dexel size

FU=fftshift(fft2(M));
Npx=size(M,1);

[nx,ny]=meshgrid(-Npx/2:Npx/2-1,-Npx/2:Npx/2-1);

kx=nx*2*pi/(Npx*dxSize);
ky=ny*2*pi/(Npx*dxSize);

k0=2*pi/lambda;
kz=sqrt(k0^2-kx.^2-ky.^2);

Prop=exp(1i*kz*z) .* exp(1i*dx*dxSize*kx) .* exp(1i*dy*dxSize*ky);
Fimagez=FU.*Prop;
Mz=ifft2(ifftshift(Fimagez));