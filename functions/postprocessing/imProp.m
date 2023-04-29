function IM=imProp(image,pxSize,lambda,z)

Nz=length(z);
[Ny,Nx]=size(image);
IM=zeros(Ny,Nx,Nz);

Fimage=fftshift(fft2(image));

%L=2*pi/(2*G.N*G.pxSize);

[xx,yy]=meshgrid(-Nx/2:Nx/2-1,-Ny/2:Ny/2-1);

kx=xx*2*pi/(Nx*pxSize);
ky=yy*2*pi/(Ny*pxSize);

k0=2*pi/lambda;
kz=sqrt(k0^2-kx.^2-ky.^2);

for iz=1:Nz
    Prop=exp(1i*kz*z(iz));
    Fimagez=Fimage.*Prop;
    IM(:,:,iz)=ifft2(ifftshift(Fimagez));
end




