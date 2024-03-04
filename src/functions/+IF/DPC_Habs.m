function map = DPC_Habs(type, Nx, Ny, r0, uj)

arguments
    type (1,:)  char {mustBeMember(type,{'ph','phase','abs'})}
    Nx   (1,1)  double  % number of columns
    Ny   (1,1)  double  % number of rows
    r0   (1,1)  double  % radius of the pupil, function of the NA
    uj   (:,2)  double  % liste of the illumination direction vectors
end

switch type
    case {'ph', 'phase'}
        eps = -1;
        fac = 1i;
    case {'abs'}
        eps = 1;
        fac = -1;
end

[X, Y] = meshgrid(-Nx/2:Nx/2-1, -Ny/2:Ny/2-1);

Ns = size(uj,1);
map = 0;
R0 =  double(X.^2 + Y.^2);
P0 = double(R0<r0^2);

for is = 1: Ns
    % positive shift
    Rs = (X+uj(is, 1)).^2 + (Y+uj(is, 2)).^2;
    Ps = double(Rs<r0^2);
    map = map + P0(uj(is,1) + Nx/2,uj(is,2)+Ny/2) * Ps;
    % negative shift
    Rs = (X-uj(is, 1)).^2 + (Y-uj(is, 2)).^2;
    Ps = double(Rs<r0^2);
    map = map + eps*P0(uj(is,1) + Nx/2,uj(is,2)+Ny/2) * Ps;
end

map = fac * map;

end
