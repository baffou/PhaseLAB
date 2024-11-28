addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))

Npx = 100;
r0  = 25; % radius of the pupil, function of the NA_obj
ri  = 20; % radius of the range of illumination, NA_ill max
Ni  = 21; % number of spots along a diameter of the array of LEDs

% absorption image
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='left');
mapLabs = IF.DPC_Habs('abs',Npx, Npx, r0, [x,y]);
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='right');
mapRabs = IF.DPC_Habs('abs',Npx, Npx, r0, [x,y]);
Habs = (mapLabs - mapRabs) ./ (mapLabs + mapRabs );
Habs(isnan(Habs)) = 0;

% phase image
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='left');
mapLph = IF.DPC_Habs('ph',Npx, Npx, r0, [x,y]);
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='right');
mapRph = IF.DPC_Habs('ph',Npx, Npx, r0, [x,y]);
Hph1 = (mapLph - mapRph) ./ (mapLph + mapRph );
Hph1(isnan(Hph1)) = 0;
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='top');
mapTph = IF.DPC_Habs('ph',Npx, Npx, r0, [x,y]);
[x, y] = IF.generateDiscArray(ri, Ni, quadrant='down');
mapDph = IF.DPC_Habs('ph',Npx, Npx, r0, [x,y]);
Hph2 = (mapTph - mapDph) ./ (mapTph + mapDph );
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
