function map = DPC_Habs(type, Nx, Ny, r0, uj)

Npx = 512;
r0  = 52; % radius of the pupil, function of the NA_obj
ri  = 20; % radius of the range of illumination, NA_ill max
Ni  = 8; % number of spots along a diameter of the array of LEDs

% absorption image
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='left');
mapLabs = H_DPC('abs',Npx, Npx, r0, [x,y]);
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='right');
mapRabs = H_DPC('abs',Npx, Npx, r0, [x,y]);
Habs1 = (mapLabs - mapRabs) ./ (mapLabs + mapRabs);
Habs1(isnan(Habs1)) = 0;
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='top');
mapTabs = H_DPC('abs',Npx, Npx, r0, [x,y]);
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='down');
mapDabs = H_DPC('abs',Npx, Npx, r0, [x,y]);
Habs2 = (mapTabs - mapDabs) ./ (mapTabs + mapDabs);
Habs2(isnan(Habs2)) = 0;

% phase image
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='left');
mapLph = H_DPC('ph',Npx, Npx, r0, [x,y]);
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='right');
mapRph = H_DPC('ph',Npx, Npx, r0, [x,y]);
Hph1 = (mapLph - mapRph) ./ (mapLabs + mapRabs);
Hph1(isnan(Hph1)) = 0;
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='top');
mapTph = H_DPC('ph',Npx, Npx, r0, [x,y]);
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='down');
mapDph = H_DPC('ph',Npx, Npx, r0, [x,y]);
Hph2 = (mapTph - mapDph) ./ (mapTabs + mapDabs);
Hph2(isnan(Hph2)) = 0;

%%
figure
subplot(3,3,1)
imagegb(mapRabs)
subplot(3,3,2)
imagegb(mapLabs)
subplot(3,3,3)
imagegb(Habs)

subplot(3,3,4)
imagegb(mapRph)
subplot(3,3,5)
imagegb(mapLph)
subplot(3,3,6)
imagegb(Hph1)

subplot(3,3,7)
imagegb(mapTph)
subplot(3,3,8)
imagegb(mapDph)
subplot(3,3,9)
imagegb(Hph2)
%%

function map = H_DPC(type, Nx, Ny, r0, uj)

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

    map = map + P0(round(uj(is,1))+Nx/2,round(uj(is,2))+Ny/2) * Ps;

    % negative shift
    Rs = (X-uj(is, 1)).^2 + (Y-uj(is, 2)).^2;
    Ps = double(Rs<r0^2);

    map = map + eps*P0(round(uj(is,1))+Nx/2,round(uj(is,2))+Ny/2) * Ps;

end

map = fac * map;

end
