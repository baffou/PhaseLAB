%% NPimaging package
% Code Discrete Dipole Approximation. To compute the dipolar moment of an assembly of interacting dipoles under illumination.

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Aug 3, 2019

% careful: all the DI properties must be equal (ie all the alpha).

function DI=DDA(DI,IL)
% DI: (Vector of) Dipole object(s), IL: Illumination object

N=numel(DI); % number of dipoles


if isempty(IL.n)
    error('A medium object needs to be assigned to the Illumination object for this kind of calculation. Please use Illumination(lambda,ME), not just Illumination(lambda).')
end




lambda = IL.lambda;
for io=1:N
    DI(io).Illumination=IL;
    DI(io).n_ext=IL.n;
end

n=IL.n;
nS=IL.nS;
direct=IL.direct;
E0=IL.E0;
pos=DI.getpos;

kk=direct*2*pi/lambda;
k0=norm(kk);

%1
%alpha=4*pi*n*n*r*r*r*(eps-n*n)/(eps+2*n*n)
%2

if isa(DI(1),'AniDipole')
    if numel(DI)>1
        error('The shine function cannot be used for an array of AniDipoles')
    end
end

if isa(DI(1),'AniDipole')
    alpha=DI(1).alpha;
else
    prop = MieTheory(DI(1));
    alpha=prop.alpha;
end


r12 = (n-nS)/(n+nS);

%% incoming electric field
EE0=zeros(3*N,1);
for ii=1:N
    %EE0(3*ii-2:3*ii)=E0*exp(1i*n*kk*pos(ii,:)');
    EE0(3*ii-2:3*ii)=E0*exp(1i*n*kk*pos(ii,:)')+r12*E0*exp(-1i*n*kk*pos(ii,:)');
    DI(ii)=DI(ii).setEE0(EE0(3*ii-2:3*ii));
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
            %S0(3*ny-2:3*ny,3*nx-2:3*nx)=-4*pi/(3*a*a*a)*Id;
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
        if R==0,error('dipole located at the interface'),end
        d=sqrt(R*R');
        T3=(3*(R'*R)-d^2*Id)/(d*d*d*d*d);
        Ssurf(3*ny-2:3*ny,3*nx-2:3*nx)=T3*[[-1 0 0];[0 -1 0];[0 0 1]];
    end
end
Ssurf=(nS*nS-n*n)/(nS*nS+n*n)*Ssurf/(4*pi*eps0);
S0=S0+Ssurf;
end

%% Calculation
if N>1,fprintf('DDA matrix inversion. Please wait...\n'),end

%Bmatrix=(eye(3*N)-eps0*alpha*S0)

EE=(eye(3*N)-eps0*alpha*S0)\EE0;
if N>1,fprintf('Done.\n'),end

EEout=reshape(EE,[3,N]).';
pout=(eps0*alpha*EEout.').';

for in=1:N
    DI(in)=DI(in).setp(pout(in,:));
end

