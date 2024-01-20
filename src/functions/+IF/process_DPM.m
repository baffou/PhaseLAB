function [OPDsimu, Tsimu, IMout] = process_DPM(IM, opt)
% OPDsimu: simulated OPD
% Tsimu: simulated normalize intensity image
% IMout: croped theoretical IM
arguments
    IM
    opt.shotNoise = false
    opt.auto = false
    opt.r0 = 2  % size of the 0th order crop [px]
    opt.Nim = 1
    opt.NimRef = 1
end

%% Definition of the grating
Nx=IM(1).Nx;
Ny=IM(1).Ny;

freq=3;
thetaGrating=31.56;

[XX,YY]=meshgrid(1:Nx,1:Ny);

G=0.5+0.5*sin(2*pi*(XX*sind(thetaGrating)+YY*cosd(thetaGrating))/freq);

Nim = numel(IM);
Itf0 = 0;
Itf0ref = 0;
sumTF = 0;
for io = 1:Nim % in case NAill ~= 0, and multiple illuminations are used, ie. multiple images. 
    % mutliplication of the Efield by the grating
    Exg=IM(io).Ex.*G;
    Eyg=IM(io).Ey.*G;
    
    Exgref=IM(io).Einc.Ex.*G;
    Eygref=IM(io).Einc.Ey.*G;
    
    % propagation in the Fourier plane
    
    FExg=fftshift(fft2(apodization(Exg,20)));
    FEyg=fftshift(fft2(apodization(Eyg,20)));
    
    FExgref=fftshift(fft2(apodization(Exgref,20)));
    FEygref=fftshift(fft2(apodization(Eygref,20)));
    
    % multiplication by the mask of the orders 0 and 1
    r0 = opt.r0; % radius of the center crop in px
    r1 = 0.9*Nx/6; % radius of the crop of the 1st order
    
    [X0, Y0]=meshgrid(-Nx/2:Nx/2-1,-Ny/2:Ny/2-1);
    R02=X0.*X0+Y0.*Y0;
    mask0=R02<r0^2;
    
    sumTF = sumTF + log(abs(FExg)+abs(FEyg));

    h=figure;
    imagegb(log(abs(FExg)+abs(FEyg)))
    fullscreen
    if opt.auto
        [x1,y1]=maxPix(abs(fftshift(fft2(G))).*double((R02>r1^2)));
    else
        [x1,y1]=ginput(1);
    end
    
    h = drawCircle(x1,y1,r1,h);
    h = drawCircle(Ny/2+1,Nx/2+1,r0,h);
    
    pause(1)
    close(h)
    
    dx=round(x1-Nx/2);
    dy=round(y1-Ny/2);
    
    mask1=R02<r1^2;
    mask1=circshift(mask1,dx,2);
    mask1=circshift(mask1,dy,1);
    
    %figure
    %imagegb(log(abs(FExg.*mask1)))
    %fullscreen
    
    FExgm=FExg.*(mask0+mask1);
    FEygm=FEyg.*(mask0+mask1);
    
    FExgrefm=FExgref.*(mask0+mask1);
    FEygrefm=FEygref.*(mask0+mask1);
    
    % repropagation to the sensor plane and computation of the interferogram
    Exc=ifft2(ifftshift(FExgm));
    Eyc=ifft2(ifftshift(FEygm));
    
    Excref=ifft2(ifftshift(FExgrefm));
    Eycref=ifft2(ifftshift(FEygrefm));
    
    Itf0 = Itf0 + abs(Exc).^2+abs(Eyc).^2;
    Itf0ref = Itf0ref + abs(Excref).^2+abs(Eycref).^2;

end

h=figure;
imagegb(sumTF)
fullscreen
[x1,y1]=maxPix(abs(fftshift(fft2(G))).*double((R02>r1^2)));
h = drawCircle(x1,y1,r1,h);
h = drawCircle(Ny/2+1,Nx/2+1,r0,h);
zoom(10)
pause(1)
close(h)



Itf0=Itf0/Nim;
Itf0ref=Itf0ref/Nim;

% figure
% subplot(1,2,1)
% imagegb(IM.E2)
% lim=get(gca,'CLim');
% colorbar
% subplot(1,2,2)
% imagegb(Itf0)
% %set(gca,'CLim',lim);
% colorbar

% processing of the interferogram


if opt.shotNoise
    noiseFunction = @poissrnd;
    if opt.NimRef == 0 || isinf(opt.NimRef)
        noiseFunctionRef = @identity;
    else
        noiseFunctionRef = @poissrnd;
    end
else
    noiseFunction = @identity;
    noiseFunctionRef = @identity;
end

EE0 = IM(1).Einc.EE0;
I0 = abs(EE0(1))^2+abs(EE0(2))^2; % avg intensity at the camera plane, if no object and no grating/mask.
Icam = mean(mean(Itf0ref));     % avg intensity at the camera,       if no object   with grating/mask.

Tr = Icam/I0; % Transmittance of the DPM device.

fwc=IM(1).Microscope.CGcam.Camera.fullWellCapacity*opt.Nim;

Itf00=noiseFunction(Itf0*(fwc/2)/(Icam));
Itf00ref=noiseFunctionRef(Itf0ref*(fwc/2)/(Icam));
Itf=apodization(Itf00,40);
Ref=apodization(Itf00ref,40);

Fitf=fftshift(fft2(Itf));
Fref=fftshift(fft2(Ref));

%figure,imagegb(log(abs(Fitf)))

Fitfs=circshift(Fitf.*mask1,-dx,2); % TODO : mask1 is the same in the algo as experimentally, why not. I now have to define a mask0 to crop the center spot and calculate the Tsimu map.
Fitfs=circshift(Fitfs,-dy,1);

IMdpm0=angle(ifft2(ifftshift(Fitfs)));

nc=20;
IMdpm0u=Unwrap_TIE_DCT_Iter(IMdpm0(nc+1:IM(1).Ny-nc,nc+1:IM(1).Nx-nc));

% correction of the tilt
IMdpm0u=IMdpm0u-mean(IMdpm0u(:));

[X0s, Y0s]=meshgrid(-Nx/2+nc:Nx/2-1-nc,-Ny/2+nc:Ny/2-1-nc);

Xn=X0s/sqrt(sum(X0s(:).*X0s(:)));
Yn=Y0s/sqrt(sum(Y0s(:).*Y0s(:)));

mx=sum(IMdpm0u(:).*Xn(:));
my=sum(IMdpm0u(:).*Yn(:));

PHIdpm=IMdpm0u-Xn*mx-Yn*my;

OPDdpm=PHIdpm*IM(1).Illumination.lambda/(2*pi);
OPDdpm=OPDdpm-median(OPDdpm(:));

OPDsimu = zeros(IM(1).Ny, IM(1).Nx);
OPDsimu(nc+1:IM(1).Ny-nc,nc+1:IM(1).Nx-nc)=OPDdpm;

%IMout = ImageQLSI(IM(1).crop(Size=IM(1).Nx-2*nc));
IMout = ImageQLSI(IM(1));

%% Computation of the intensity image :
% crop of the central part of the Fourier space
mask00=R02<r1^2;
Tdhm0 = ifft2(ifftshift(Fitf.*mask00));
% crop of the central part of the Fourier space, when there is no object
Trefdhm0 = ifft2(ifftshift(Fref.*mask00));
% Intensity image when discarding the order 1 crop of the mask, and when there
% is no object
FExgrefm0=FExgref.*(mask0);
FEygrefm0=FEygref.*(mask0);
Excref0=ifft2(ifftshift(FExgrefm0));
Eycref0=ifft2(ifftshift(FEygrefm0));

Itf0ref0=(abs(Excref0).^2+abs(Eycref0).^2)*fwc/(4*I0);



Tdhm = (Tdhm0 - Itf0ref0)./(Trefdhm0 - Itf0ref0);  % (Tdhm-Iref)/

% figure
% subplot(1,4,1)
% imagegb(Tdhm0)
% subplot(1,4,2)
% imagegb(Trefdhm0)
% subplot(1,4,3)
% imagegb(Itf0ref0)
% subplot(1,4,4)
% imagegb(Tdhm)
% linkAxes

Tsimu=Tdhm;%(nc+1:IM(1).Ny-nc,nc+1:IM(1).Nx-nc);


