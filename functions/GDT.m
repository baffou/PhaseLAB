%% NPimaging package
% Code Green Dyadic Tensor. To compute the dipolar moment of a meshed nanoparticle under illumination.

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Aug 3, 2019

function NPout=GDT(NP,IL)
% NP: Nanoparticle object, IL: Illumination object

NPout=NP;

if isempty(IL.n)
    error('A Medium object needs to be assigned to the Illumination object in this kind of calculation')
end

NPout.mesh.E0=IL.E0;
lambda = IL.lambda;
NPout.Illumination=IL;
eps = NPout.eps;
n=IL.n;
nS=IL.nS;
NPout.n_ext=n;
a=NPout.mesh.a;
direct=IL.direct;
E0=IL.E0;
pos=NPout.mesh.pos;
N=NPout.mesh.N;

kk=direct*2*pi/lambda;
k0=norm(kk);
chi=(eps-n*n)*a*a*a;

%% incoming electric field
r12 = (n-nS)/(n+nS);
EE0=zeros(3*N,1);
for ii=1:N
    %EE0(3*ii-2:3*ii)=E0*exp(1i*n*kk*pos(ii,:)');
    EE0(3*ii-2:3*ii)=E0*exp(1i*n*kk*pos(ii,:)')+r12*E0*exp(-1i*n*kk*pos(ii,:)');
end

%% Construction of the Matrix to be inverted
Id=eye(3);
S0=zeros(3*N,3*N);
for ny=1:N
    for nx=1:N
        if ny~=nx
            R=pos(nx,:)-pos(ny,:);
            d=sqrt(R*R');
            T1=(   R'*R -d^2*Id)/(d*d*d);
            T2=(3*(R'*R)-d^2*Id)/(d*d*d*d);
            T3=(3*(R'*R)-d^2*Id)/(d*d*d*d*d);
            S0(3*ny-2:3*ny,3*nx-2:3*nx)=(-k0^2*n*n*T1-1i*n*k0*T2+T3)*exp(1i*n*k0*d);
        else
            S0(3*ny-2:3*ny,3*nx-2:3*nx)=-4*pi/(3*a*a*a)*Id;
        end
    end
end

eps0=8.854187817e-12;
S0=S0/(4*pi*eps0*n*n);

if nS~=n
Ssurf=zeros(3*N,3*N);
for ny=1:N
    for nx=1:N
        R=pos(nx,:)-pos(ny,:).*[1,1,-1];
        d=sqrt(R*R');
        T3=3*(R'*R)-d^2*Id/(d*d*d*d*d);
        Ssurf(3*ny-2:3*ny,3*nx-2:3*nx)=T3*[[-1 0 0];[0 -1 0];[0 0 1]];
%        Ssurf(3*ny-2:3*ny,3*nx-2:3*nx)=T3*[[-1 0 0];[0 -1 0];[0 0 1]]*exp(1i*n*k0*d);  % in principle this exp is not put. Just to check the difference
    end
end
Ssurf=(nS*nS-n*n)/(nS*nS+n*n)*Ssurf/(4*pi*eps0);
S0=S0+Ssurf;
end

%% Calculation
fprintf('DDA matrix inversion. Please wait...\n')
EE=(eye(3*N)-eps0*chi*S0)\EE0;
fprintf('Done.\n')

NPout.mesh.EE=reshape(EE,[3,N]).';
NPout.mesh.EE0=reshape(EE0,[3,N]).';
NPout.mesh.p=eps0*chi*NPout.mesh.EE;
NPout.mesh.chi=chi;
NPout.Illumination=IL;

