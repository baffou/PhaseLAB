function IM=imProp2(image,pxSize,lambda,z)
% in the second version, I don't use fftshift

Nz=length(z);
[Ny,Nx]=size(image);
IM=zeros(Ny,Nx,Nz);

Fimage=fft2(image);

[xx,yy]=meshgrid(1:Nx,1:Ny);

kx=xx*2*pi/(Nx*pxSize);
ky=yy*2*pi/(Ny*pxSize);

k0=2*pi/lambda;
kz=sqrt(k0^2-kx.^2-ky.^2);

for iz=1:Nz
    Prop=exp(1i*kz*z(iz));
    Fimagez=Fimage.*Prop;
    IM(:,:,iz)=ifft2(Fimagez);
end




