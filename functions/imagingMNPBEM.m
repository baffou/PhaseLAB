%% NPimaging package
% Computes the image of a collection of dipoles through a microscope

% authors: Samira Khadir, Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 29, 2019


%function image=imagingMNPBEM(sig,op,MI)
% imagingMNPBEM(farfield,spec)
% farfield: compstruct MNPBEM object. Contains the complex amplitudes and the nvec f.p.nvec
% spec: contains the refractive indices of the media and again the nvec: spec.pinfty.nvec
% MI: PhaseLAB Microscope object


nM=numel(op.layer.eps);

if nM==1
    n  = sqrt(op.layer.eps{1}(1));            % refractive index of the background medium of the dipole
    nS = n;           % refractive index of the microscope coverslip and the imersion medium
elseif nM==2
    n  = sqrt(op.layer.eps{1}(1));            % refractive index of the background medium of the dipole
    nS = sqrt(op.layer.eps{2}(1));           % refractive index of the microscope coverslip and the imersion medium
end


M  = MI.M;            % Microscope magnification
NA = MI.NA;           % Numerical aperture of the microscope objective

if NA>nS
    error('NA should be smaller than n')
end

%% excitation field
lambda = sig.enei*1e-9;             % illumination wavelength (m)

k0 = 2*pi/lambda;            % wavevector in vacuum

tr = 2*n/(n+nS);            % transmission coefficient through the interface
%e0 = IL.e0;  % incident electic field

%r12 = (n-nS)/(n+nS);           % reflection coefficient at the interface
Npx = 50;        % 3*Npx+1: nb of pixel of the side of the image
ImSize=5e-6;
zoom=Npx*lambda/ImSize;
kmax = zoom*k0;
dk = kmax/(Npx);                   % pixel size in fourier space
kxx = -kmax:dk:kmax; % x component of wavevector
kyy = -kmax:dk:kmax; % y component of wavevector

Nkx=numel(kxx);
Nky=numel(kyy);

dir=zeros(Nkx*Nky,3);
for ikx=1:numel(kxx)
    kx=kxx(ikx);
    kx0=kx/(n*k0);
    %kprimex=kx/M;
    %kprimex0=kprimex/k0;
    for iky=1:numel(kyy)
        ky=kyy(iky);
        ky0=ky/(n*k0);
        %kprimey=ky/M;
        %kprimey0=kprimey/k0;
        
        if sqrt(kx*kx+ky*ky) <= NA*k0     % cutoff filter; taking into account the numerical aperture of the objective
            %ga=sqrt(nS^2*k0^2-kx^2-ky^2);
            ga0=sqrt(nS^2*k0^2-kx^2-ky^2)/(nS*k0);
            %gab=sqrt(n^2*k0^2-kx^2-ky^2);
            %gab0=sqrt(n^2*k0^2-kx^2-ky^2)/(n*k0);
            %kv = [kx0;ky0;ga0];               % wavevector in the medium of refractive index n
            %kvb = [kx0;ky0;gab0];             % wavevector in the medium of refractive index nb
            
            dir(ikx+(iky-1)*Nkx,1)=kx0;
            dir(ikx+(iky-1)*Nkx,2)=ky0;
            dir(ikx+(iky-1)*Nkx,3)=ga0;
        end
    end
end
        
    
spec = spectrum( dir, op );

%  farfield radiation
1
f = farfield( spec, sig );
2
Ekprimex = zeros(Nky,Nkx);
Ekprimey = zeros(Nky,Nkx);
Ekprimez = zeros(Nky,Nkx);
3
for ikx=1:numel(kxx)
    for iky=1:numel(kyy)
        Ekprimex(iky,ikx)=f.e(ikx+(iky-1)*Nkx,1);
        Ekprimey(iky,ikx)=f.e(ikx+(iky-1)*Nkx,2);
        Ekprimez(iky,ikx)=f.e(ikx+(iky-1)*Nkx,3);
    end
end
4
% initialization
%uz = [0;0;1];

%% Computation of the scattered field at image plane
Expp = (1/M)*fftshift(fft2(ifftshift(Ekprimex)))*dk*dk;
Eypp = (1/M)*fftshift(fft2(ifftshift(Ekprimey)))*dk*dk;
Ezpp = (1/M)*fftshift(fft2(ifftshift(Ekprimez)))*dk*dk;

5


%% Total field image plane

dr = 2*pi/((2*Npx+1)*dk); %pixel size at the image plane (m)
eexim = [0 0 0];% tr/M*sqrt(nS)*e0*exp(1i*nS*k0*zo)*IL.polar; % excitation field image plane
Eixtot = eexim(1)+Expp;
Eiytot = eexim(2)+Eypp;
image=ImageEM(eexim,Eixtot,Eiytot,Ezpp);
image.zoom=zoom;
image.pxSize0=dr;
image.Illumination=Illumination(lambda);
image.Microscope=MI;

6

image.figure





