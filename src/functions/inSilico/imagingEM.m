%% Compute the image of an ImageEM object defined at the object plane,
% applying the blurring effect due to the NA of the detection


function IMout = imagingEM(IM,IL,MI)
arguments
    IM ImageEM
    IL Illumination = IM.Illumination
    MI Microscope = IM.Microscope
end

% imaging(DIs,IL,MI[,ImSize,Npx])
% DIs: array of Dipole objects, or Nanoparticle object
% IL: Illumination object
% MI: Objective or Microscope object, Objetive being a superclass of Microscope

fEx = fftshift(fft2(IM.Ex));
fEy = fftshift(fft2(IM.Ey));
fE0x = fftshift(fft2(IM.Einc.Ex));
fE0y = fftshift(fft2(IM.Einc.Ey));

[Ny, Nx] = size(IM.Ex);

if isa(MI,'Microscope')
elseif isa(MI,'Objective')
    MI = Microscope(MI);
else
    error('The third input must be either an Objective or a Microscope object')
end

pxSize = MI.pxSize;
ImSize = [Ny, Nx]*pxSize;

%% Microscope paramaters

if isempty(IL.n)
    error('A medium object needs to be assigned to the Illumination object for this kind of calculation. Please use Illumination(lambda,ME), not just Illumination(lambda).')
end

if MI.NA>IL.nS
    error('NA should be smaller than n')
end

%% excitation field

k0 = IL.k0;            % wavevector in vacuum

%r12 = (n-nS)/(n+nS);           % reflection coefficient at the interface
kmaxy = pi*Ny/ImSize(1);
kmaxx = pi*Nx/ImSize(2);

%dk = kmax/(Npx);        % other valid expression
dkx = 2*pi/ImSize(2);        % pixel size in Fourier space
dky = 2*pi/ImSize(1);        % pixel size in Fourier space
kxx = -kmaxx:dkx:kmaxx-dkx; % x component of wavevector
kyy = -kmaxy:dky:kmaxy-dky; % y component of wavevector


[Kx,Ky] = meshgrid(kxx, kyy);

%% Computation of the scattered field at Fourier plane

mask = sqrt(Kx.*Kx + Ky.*Ky) < MI.NA*k0;     % cutoff filter; taking into account the numerical aperture of the objective

fEx = fEx.*mask;
fEy = fEy.*mask;
fE0x = fE0x.*mask;
fE0y = fE0y.*mask;

Ex = ifft2(ifftshift(fEx));
Ey = ifft2(ifftshift(fEy));
E0x = ifft2(ifftshift(fE0x));
E0y = ifft2(ifftshift(fE0y));

IMout = ImageEM(Ex, Ey, IM.Ez, E0x, E0y, IM.Einc.Ez, "Microscope", IM.Microscope, "Illumination", IM.Illumination);


