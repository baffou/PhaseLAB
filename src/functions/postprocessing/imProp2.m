function [image2, Ph]=imProp2(image,pxSize,lambda,z,n)
% In this second version, I don't use fftshift

arguments
    image
    pxSize
    lambda
    z
    n = 1
end

Nz=length(z);
[Ny,Nx]=size(image);
image2=zeros(Ny,Nx,Nz);
Ph=zeros(Ny,Nx,Nz);

Fimage=fft2(image);

%L=2*pi/(2*G.N*G.pxSize);

[xx,yy]=meshgrid(-Nx/2:Nx/2-1,-Ny/2:Ny/2-1);

kx=xx*2*n*pi/(Nx*pxSize);
ky=yy*2*n*pi/(Ny*pxSize);

k0=2*n*pi/lambda;
kz=sqrt(k0^2-kx.^2-ky.^2);

for iz=1:Nz
    Prop=exp(1i*kz*z(iz));
    Fimagez=Fimage.*Prop;
    image2(:,:,iz)=ifft2(Fimagez);
    Ph(:,:,iz) = Unwrap_TIE_DCT_Iter(angle(image2(:,:,iz)));
end




