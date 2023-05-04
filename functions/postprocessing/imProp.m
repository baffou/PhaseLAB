function [image2, Ph]=imProp(image,pxSize,lambda,z,opt)
arguments
    image
    pxSize    % pixel size [m]
    lambda    % wavelength
    z         % defocus

    opt.n = 1 % refractive index of the propagation medium

    opt.dx = 0 % dx and dy shift the phase of the image by dx and dy pixels
    opt.dy = 0 %  (not necessarily integers)
end

Nz=length(z);
[Ny,Nx]=size(image);
image2=zeros(Ny,Nx,Nz);
if nargout == 2
    Ph=zeros(Ny,Nx,Nz);
end
Fimage=fftshift(fft2(image));

%L=2*pi/(2*G.N*G.pxSize);

[xx,yy]=meshgrid(-Nx/2:Nx/2-1,-Ny/2:Ny/2-1);

kx=xx*2*pi/(Nx*pxSize);
ky=yy*2*pi/(Ny*pxSize);

k0=2*opt.n*pi/lambda;
kz=sqrt(k0^2-kx.^2-ky.^2);

for iz=1:Nz
    Prop=exp(1i*kz*z(iz)) .* exp(1i*opt.dx*pxSize*kx) .* exp(1i*opt.dy*pxSize*ky);
    Fimagez=Fimage.*Prop;
    image2(:,:,iz)=ifft2(ifftshift(Fimagez));
    if nargout == 2
        Ph(:,:,iz) = Unwrap_TIE_DCT_Iter(angle(image2(:,:,iz)));
    end
end




