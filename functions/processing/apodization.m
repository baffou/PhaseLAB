function [im, mask] = apodization(im0,npx)

if nargin == 1
    npx=20;
end

%npx=100;
%im0=Itf(1).Itf;

[Ny, Nx] = size(im0);

mask=ones(Ny,Nx);

m0=mean(im0(:));

[~,hBand]=meshgrid(0:Nx-1,0:npx-1);
vBand=meshgrid(0:npx-1,0:Ny-1);
hBand=hBand/max(hBand(:));
vBand=vBand/max(vBand(:));

mask(1:npx,:)=mask(1:npx,:).*sin(hBand*pi/2);
mask(:,1:npx)=mask(:,1:npx).*sin(vBand*pi/2);
mask(1+Ny-npx:Ny,:)=mask(1+Ny-npx:Ny,:).*sin(hBand(npx:-1:1,:)*pi/2);
mask(:,1+Nx-npx:Nx)=mask(:,1+Nx-npx:Nx).*sin(vBand(:,npx:-1:1)*pi/2);

im=(im0-m0).*mask+m0;


%figure
%imagegb(im)

