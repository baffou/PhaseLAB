function [EE, EE0] = GDT0(posList,a0,chiTensor,IL)
% run a Green Dyadic Tensor simulation
arguments
    posList   (:,3) double % Coordinates of the mesh elements
    a0        (1,1) double % mesh parameter
    chiTensor (3,3) double % Chi tensor of the material
    IL        Illumination % Incident light
end

eps0 = 8.8541878128e-12;
Np = size(posList,1);
EE0 = Eincident(IL,posList,'reshape',false);
n0 = IL.n;
nS = IL.nS;
kk = IL.direct*2*pi/IL.lambda;
k0 = norm(kk);
kan = k0*a0*n0;
            
%% Construction of the Matrix to be inverted
Id = eye(3);
S0 = zeros(3*Np,3*Np);
for ny = 1:Np
    for nx = 1:Np
        if ny ~= nx
            Rn = (posList(nx,:)-posList(ny,:))/a0;
            dn = sqrt(Rn*Rn');
            T1 =    (   Rn'*Rn  - dn^2*Id)/(dn*dn*dn);
            T2 =    (3*(Rn'*Rn) - dn^2*Id)/(dn*dn*dn*dn) ;
            T3 =    (3*(Rn'*Rn) - dn^2*Id)/(dn*dn*dn*dn*dn);
            S0(3*ny-2:3*ny,3*nx-2:3*nx) = chiTensor*(-kan^2*T1-1i*kan*T2+T3)*exp(1i*kan*dn);
        else
            %S0(3*ny-2:3*ny,3*nx-2:3*nx) = -4*pi*chi/(3*a*a*a)*Id;

            % Correction suggested by ChatGPT:
            S0(3*ny-2:3*ny,3*nx-2:3*nx) = (-4*pi*chiTensor/3 + 1i*2*(kan/n0)^3/3*chiTensor) ;

        end
    end
end

S0 = S0/(4*pi*eps0*n0*n0);

if nS~=n0
    Ssurf = zeros(3*Np,3*Np);
    for ny = 1:Np
        for nx = 1:Np
            Rn = (posList(nx,:)-posList(ny,:).*[1,1,-1])/a0;
            dn = sqrt(Rn*Rn');
            T3 = (3*(Rn'*Rn)-dn^2*Id)/(dn*dn*dn*dn*dn);
            Ssurf(3*ny-2:3*ny,3*nx-2:3*nx) = chiTensor * T3*[[-1 0 0];[0 -1 0];[0 0 1]];
            %        Ssurf(3*ny-2:3*ny,3*nx-2:3*nx) = T3*[[-1 0 0];[0 -1 0];[0 0 1]]*exp(1i*n*k0*d);  % in principle this exp is not put. Just to check the difference
        end
    end
    Ssurf = (nS*nS-n0*n0)/(nS*nS+n0*n0)*Ssurf/(4*pi*eps0);
    S0 = S0+Ssurf;
end

%% Calculation
fprintf('DDA matrix inversion. Please wait...\n')
EE = (eye(3*Np)-eps0*S0)\EE0;
fprintf('Done.\n')

