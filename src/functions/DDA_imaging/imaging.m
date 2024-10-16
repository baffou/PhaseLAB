%% NPimaging package
% Computes the image of a collection of dipoles through a microscope

% authors: Samira Khadir, Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 29, 2019


function IM = imaging(DIs,IL,MI,Npx)
% imaging(DIs,IL,MI[,ImSize,Npx])
% DIs: array of Dipole objects, or Nanoparticle object
% IL: Illumination object
% MI: Objective or Microscope object, Objetive being a superclass of Microscope


if isa(MI,'Microscope')
elseif isa(MI,'Objective')
    MI = Microscope(MI);
else
    error('The third input must be either an Objective or a Microscope object')
end

if nargin==3
    Npx = MI.CGcam.Camera.Ny;
end
pxSize = MI.pxSize;
ImSize = Npx*pxSize;

if isa(DIs(1),'Nanoparticle')
    NP = DIs;
    if NP.Illumination.identity~=IL.identity
        warning('The illumination used to shine the nanoparticle is not the one used to compute the image')
    end
    if isempty(NP.mesh.p)
        error('The Nanoparticle must be illuminated before imaging')
    end
    clear DIs
    Nd = numel(NP.mesh.pos)/3;
    DI0 = Dipole(NP.mat,NP.mesh.a/2);
    DIs = repmat(DI0,Nd,1);
    for id = 1:Nd
        DIs(id) = DIs(id).setp(NP.mesh.p(id,:));
        DIs(id) = DIs(id).moveTo(NP.mesh.pos(id,1),NP.mesh.pos(id,2),NP.mesh.pos(id,3));
        DIs(id).Illumination = NP.Illumination;
    end
end

if isempty(DIs(1).p)
    error('The Dipole(s) must be illuminated before imaging')
end


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

k0 = IL.k0;            % wavevector in vacuum
tr = IL.tr;            % transmission coefficient through the interface
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

NDI = numel(DIs);

ILlist = [DIs(:).Illumination];
if [ILlist(:).identity]~=IL.identity
    warning('The illumination used to shine the nanoparticle is not the one used to compute the image')
end



if NDI>1,f = waitbar(0,'please wait');end
    
for id = 1:NDI

        
    if NDI>1,waitbar(id/numel(DIs),f,['NP imaging: ' num2str(id) '/' num2str(numel(DIs)) ' dipoles']);end
    DI = DIs(id);
    

    if DI.Illumination.identity~=IL.identity
        warning('The illumination used to compute the image is not the one used to create the dipole')
        disp(DI.Illumination)
        disp(IL)
    end
    
    %% Dipole created by a nanosphere
    % Polarization of the dipole (Ex: alpha = pi/2, betha = 0 --> the dipole
    % oriented according to x direction)
    
    Q = DI.p.';
    
    %% defocus and position of the dipole
    xQ = DI.x;  % position of the dipole according to the interface plane (m)
    yQ = DI.y;  % position of the dipole according to the interface plane (m)
    zQ = DI.z;  % position of the dipole according to the interface plane (m)
    
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
           
            if sqrt(kx*kx+ky*ky) <= NA*k0     % cutoff filter; taking into account the numerical aperture of the objective
                
                ga = sqrt(nS^2*k0^2-kx^2-ky^2);
                ga0 = sqrt(nS^2*k0^2-kx^2-ky^2)/(nS*k0);
                
                gab = sqrt(n^2*k0^2-kx^2-ky^2);
                gab0 = sqrt(n^2*k0^2-kx^2-ky^2)/(n*k0);
                
                kv = [kx0;ky0;ga0];               % wavevector in the medium of refractive index n
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
                    s=s/norm(s);
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

%                 if ikx==202 && iky==201
%                     s
%                     p
%                     sgfdghf
%                 end

                Q1 = Q-dot(conj(kvb),Q)*kvb; % radiated field of the dipole
                Qs = ts*dot(conj(Q1),sb)*s;  % transmission of s component of the radiated field
                Qp = tp*dot(conj(Q1),pb)*p;  % transmission of p component of the radiated field
                % Le probl�me est avec Qp qui vaut z�ro dans le cas
                % pol=[010] if pour k normal � la surface

                
                eps0 = 8.8541878128e-12;     % vacuum permittivity
                % planewave expantion of the radiated electric field
                %Eka = 1i*k0*k0/(8*pi*pi*eps0)*(1/gab)*(Qs+Qp)*exp(-1i*gab*zQ+1i*ga*zo);
                Eka = 1i*k0*k0/(8*pi*pi*eps0)*(1/gab)*(Qs+Qp)*exp(-1i*(gab*zQ+kx*xQ+ky*yQ)+1i*ga*zo) ;
                % Computation of the electric field after rotation
                gaprime = sqrt(k0^2-kprimex^2-kprimey^2);
                gaprime0 = sqrt(k0^2-kprimex^2-kprimey^2)/k0;
                kvprime = [kprimex0;kprimey0;gaprime0];
                
                pprime1 = cross(kvprime,s);
                pprime = cross(kvprime,s)/norm(pprime1);
                
                Ekprime = sqrt(ga/gaprime)*(dot(conj(Eka),s)*s+dot(conj(Eka),p)*pprime);
                
%                 if (sb1==0)
%                     1i*k0/(8*pi*pi*n*eps0)*exp(-1i*(n*k0*zQ)+1i*nS*k0*zo)*Qs;
%                     
%                     % these two quantities are equal:
%                     Ekprime
%                     1i*sqrt(nS)*k0/(8*pi*pi*n*eps0)*exp(1i*(n*k0*zQ)-1i*nS*k0*zo) * Qs;
%                     rr=ts*dot(conj(DI.p.'),(abs(DI.p/norm(DI.p))).')*(abs(DI.p/norm(DI.p))).';
%                     %rr=ts*dot(conj(DI.p.'),(abs(DI.p/norm(DI.p))).')*(abs(DI.p/norm(DI.p))).'
%                     dot(conj(DI.p.'),(abs(DI.p/norm(DI.p))).')*abs(DI.p/norm(DI.p));
%                     (DI.p(:).'*(abs(DI.p(:)/norm(DI.p))))*abs(DI.p(:)/norm(DI.p));
%                     DI.p.';
%                     abs(DI.p/norm(DI.p));
%                     ss=DI.p.';
%                     
%                     EE0im = tr/M*sqrt(nS)*e0*exp(1i*nS*k0*zo)*IL.polar;
%                     aa=1/(IL.eps0*norm(DI.EE0)^2)*DI.EE0'*DI.p.';
%                     bb=1i*2*n/k0*Ekprime(1)/EE0im(1);
%                     aa/bb;
%                     
%                     
%                     %Ekprime(1)
% 
%                     ikxc=ikx;
%                     ikyc=iky;
% %                    1i*k0*k0/(8*pi*pi*eps0)*(1/(n*k0))*Qs*exp(-1i*(n*k0*zQ))*sqrt(nS)
%                     %Ekprime0=Ekprime(1);
% 
%                 end
                
                Ekprimex(iky,ikx) = Ekprimex(iky,ikx) + Ekprime(1);
                Ekprimey(iky,ikx) = Ekprimey(iky,ikx) + Ekprime(2);
                Ekprimez(iky,ikx) = Ekprimez(iky,ikx) + Ekprime(3);
            end % if k<NA*k0
        end    % end for kyy
    end        % end for kxx

    %    fprintf('Ex for the dipole #%d:',id)
    %    Ekprimex(ikyc,ikxc)/id

end  % end sum over dipoles
if NDI>1,close(f),end
%% Computation of the scattered field at image plane
%Ekprimex(201,201)
%A=fft2(ifftshift(Ekprimex));
%sum(A(:))/(401*401)

Expp = (1/M)*fftshift(fft2(ifftshift(Ekprimex)))*dk*dk;
Eypp = (1/M)*fftshift(fft2(ifftshift(Ekprimey)))*dk*dk;
Ezpp = (1/M)*fftshift(fft2(ifftshift(Ekprimez)))*dk*dk;
    
    %pxSize = 2*pi/((2*Npx+1)*dk);
%    Eim0 = tr/M*sqrt(nS)*e0*exp(1i*nS*k0*zo)*IL.polar;
    
    % these two quantities are equal:
    %aa = sum(Expp(:))
    %sumExpp = (2*pi)^2/(M*pxSize^2)*Ekprimex(201,201)
    
%alphaS = IM.EE0(1)*sum(1-IM.Ex(:)/IM.EE0(1))
%     -1.292686673178455e+08 + 9.007486741265880e+07i
% d'apr�s alpha_Image.m :
%alphaSn = sum(1-IM.Ex(:)/IM.EE0(1))
%   9.928227747032447e+02 - 6.918024425499526e+02i
%alphaS/IM.EE0(1)
%   9.928227747032447e+02 - 6.918024425499526e+02i
%alphaEx = -1i*2*n/k0*(sumExpp/Eim0(1))*pxSize*pxSize;
%alphaEx = -1i*8*pi^2*n*Ekprimex(201,201)/(k0*M*Eim0(1))
%   2.903215902323102e-19 + 4.166476858744075e-19i
    
%% Total field image plane
%dr = 2*pi/((2*Npx+1)*dk); %pixel size at the image plane (m)
eexim = tr/M*sqrt(nS)*e0*exp(1i*nS*k0*zo)*IL.polar; % excitation field image plane
Eixtot = eexim(1)+Expp;
Eiytot = eexim(2)+Eypp;
IM = ImageEM(Eixtot,Eiytot,Ezpp,eexim);
IM.Illumination = IL;
IM.Microscope = MI;



