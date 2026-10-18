function [Ex, Ey, Ez, E0] = imaging0(dipoles,posList,IL,MI,opt)
% Computes the complex image at the image plane of a microscope created by
% dipoles in the object plane

arguments
    dipoles (:,3) double % complex dipole moments
    posList (:,3) double % coordinates of the dipoles
    IL Illumination      % Incident illumination at the object plane
    MI Microscope        % Microscope used for imaging
    opt.Npx double = []  % Number of pixels in the image
    opt.norm logical = false % normalizes the output xo that IL.e0 is the incident field at the image plane
    opt.rotation = true  % Apply the rotation algorithm
end

norm0 = opt.norm;

if isempty(opt.Npx)
    Npx = MI.CGcam.Camera.Ny;
else
    Npx = opt.Npx;
end

pxSize = MI.pxSize;
ImSize = Npx*pxSize;

%% Microscope paramaters

if isempty(IL.n)
    error('A medium object needs to be assigned to the Illumination object for this kind of calculation. Please use Illumination(lambda,ME), not just Illumination(lambda).')
end

n  = IL.n;            % refractive index of the background medium of the dipole
nS = IL.nS;           % refractive index of the microscope coverslip and the imersion medium
M  = MI.M;            % Microscope magnification
NA = MI.NA;           % Numerical aperture of the microscope objective


zo = MI.zo;

if NA>nS
    error('NA should be smaller than n')
end

%% excitation field

k0 = IL.k0;  % wavevector in vacuum
tr = IL.tr;  % transmission coefficient through the interface
e0 = IL.e0;  % incident electic field

%r12 = (n-nS)/(n+nS);           % reflection coefficient at the interface
kmax = pi*Npx/ImSize;

%dk = kmax/(Npx);        % other valid expression
dk = 2*pi/ImSize;        % pixel size in Fourier space
kxx = -kmax:dk:kmax-dk; % x component of wavevector
kyy = -kmax:dk:kmax-dk; % y component of wavevector
% initialization
Ekprimex = zeros(length(kxx),length(kyy));
Ekprimey = zeros(length(kxx),length(kyy));
Ekprimez = zeros(length(kxx),length(kyy));
uz = [0;0;1];

Nd = size(dipoles,1);

if Nd>1,f = waitbar(0,'please wait');end
    
for id = 1:Nd

    if Nd>1,waitbar(id/Nd,f,['NP imaging: ' num2str(id) '/' num2str(Nd) ' dipoles']);end
    
    %% Dipole created by a nanosphere
    % Polarization of the dipole    
    %Q = DI.p.';
    Q = dipoles(id,:).';
    %% defocus and position of the dipole
    xQ = posList(id,1);  % position of the dipole according to the interface plane (m)
    yQ = posList(id,2);  % position of the dipole according to the interface plane (m)
    zQ = posList(id,3);  % position of the dipole according to the interface plane (m)
    
    %% Computation of the scattered field at Fourier plane
    
    for ikx = 1:numel(kxx)
        kx = kxx(ikx);
        kx0 = kx/(n*k0);
        kprimex = kx/M;
        kprimex0 = kprimex/k0;
        for iky = 1:numel(kyy)
            ky = kyy(iky);
            ky0 = ky/(n*k0);
            kprimey = ky/M;
            kprimey0 = kprimey/k0;
           
            if sqrt(kx*kx+ky*ky) < NA*k0     % cutoff filter; taking into account the numerical aperture of the objective
                
                ga  = sqrt(nS^2*k0^2-kx^2-ky^2);
                ga0 = sqrt(nS^2*k0^2-kx^2-ky^2)/(nS*k0);
                
                gab  = sqrt(n^2*k0^2-kx^2-ky^2);
                gab0 = sqrt(n^2*k0^2-kx^2-ky^2)/(n*k0);
                
                kv  = [kx0;ky0;ga0];               % wavevector in the medium of refractive index n
                kvb = [kx0;ky0;gab0];             % wavevector in the medium of refractive index nb
                
                % transmission coefficiens for s and p polarizations
                ts = 2*gab/(gab+ga);
                tp = 2*n*nS*gab/(nS^2*gab+n^2*ga);
                
                % s and p basis in the medium of refractive index nS
                s1 = cross(uz,kv);
                if (s1==0)
                    %s = [1;0;0];
                    %s = (IL.polar).';
                    s = abs(IL.polar).';
                    s = s/norm(s);
                    %s = (abs(DI.p/norm(DI.p))).';% norm vector along the dipole
                    
                    p = [0;0;0];
                
                else
                    s = cross(uz,kv)/norm(s1);
                    p1 = cross(kv,s);
                    p = cross(kv,s)/norm(p1);
                end
                
                % s and p basis in the medium of refractive index n
                sb1 = cross(uz,kvb);
                if (sb1==0)
                    %sb=[1;0;0];
                    sb = abs(IL.polar).';
                    sb = sb/norm(sb);
                    %sb=(abs(DI.p/norm(DI.p))).';% norm vector along the dipole
                                    % ASSUME THE DIPOLE IS LINEAR! WHAT IF IT IS EXCITED WITH
                                    % A CIRCULARLY POLARIZED LIGHT?, OR IF IT IS A DIPOLE WITHIN
                                    % A Nanoparticle  OBJECT
                    pb = [0;0;0];

                else

                    sb = cross(uz,kvb)/norm(sb1);
                    pb1 = cross(kvb,sb);
                    pb = cross(kvb,sb)/norm(pb1);
                end

                Q1 = Q-dot(conj(kvb),Q)*kvb; % radiated field of the dipole
                Qs = ts*dot(conj(Q1),sb)*s;  % transmission of s component of the radiated field
                Qp = tp*dot(conj(Q1),pb)*p;  % transmission of p component of the radiated field
                % Le problème est avec Qp qui vaut zéro dans le cas
                % pol=[010] if pour k normal à la surface
               
                eps0 = 8.8541878128e-12;     % vacuum permittivity

                Eka = 1i*k0*k0/(8*pi*pi*eps0)*(1/gab)*(Qs+Qp)*exp(-1i*(gab*zQ+kx*xQ+ky*yQ)+1i*ga*zo) ;
                
                if opt.rotation
                    % Computation of the electric field after rotation
                    gaprime = sqrt(k0^2-kprimex^2-kprimey^2);
                    gaprime0 = sqrt(k0^2-kprimex^2-kprimey^2)/k0;
                    kvprime = [kprimex0;kprimey0;gaprime0];
                    
                    pprime1 = cross(kvprime,s);
                    pprime = cross(kvprime,s)/norm(pprime1);
                    
                    Ekprime = sqrt(ga/gaprime)*(dot(conj(Eka),s)*s+dot(conj(Eka),p)*pprime);
                else
                    Ekprime = Eka;
                end
                Ekprimex(iky,ikx) = Ekprimex(iky,ikx) + Ekprime(1);
                Ekprimey(iky,ikx) = Ekprimey(iky,ikx) + Ekprime(2);
                Ekprimez(iky,ikx) = Ekprimez(iky,ikx) + Ekprime(3);

            end % if k<NA*k0
        end    % end for kyy
    end        % end for kxx


end  % end sum over dipoles
if Nd>1,close(f),end
%% Computation of the scattered field at image plane

Expp = (1/M)*fftshift(fft2(ifftshift(Ekprimex)))*dk*dk;
Eypp = (1/M)*fftshift(fft2(ifftshift(Ekprimey)))*dk*dk;
Ezpp = (1/M)*fftshift(fft2(ifftshift(Ekprimez)))*dk*dk;
    
    
%% Total field image plane
%dr = 2*pi/((2*Npx+1)*dk); %pixel size at the image plane (m)
eexim = tr/M*sqrt(nS)*e0*exp(1i*nS*k0*zo)*IL.polar; % excitation field image plane
Eixtot = eexim(1)+Expp;
Eiytot = eexim(2)+Eypp;

if norm0
    cst = tr/M*sqrt(nS)*e0;
    Ex = Eixtot/cst;
    Ey = Eiytot/cst;
    Ez = Ezpp/cst;
    E0 = eexim/cst;
    
else
    Ex = Eixtot;
    Ey = Eiytot;
    Ez = Ezpp;
    E0 = eexim;
end
