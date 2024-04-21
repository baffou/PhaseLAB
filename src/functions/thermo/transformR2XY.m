%% FUNCTION THAT TRANSFORMS A 1D PROFILE INTO A 2D PROFILE WITH RADIAL SYMMETRY.

function Image = transformR2XY(rpx,F,nx, ny, pxSize)
% fonction à optimiser, là je considère des Rx et Ry de trop grandes tailles. Attention à ce décalage de 0.5 en corrigeant dans le futur ce code.
%
% rhoF=RHO;
% F=GreenRHOZ(52,:);
% pxSize=444;
% ny=300;
% nx=300;
% cette fonction F est censée démarrer à pxSize/2 Typiquement:

rhoF = rpx.z;

X = -nx+0.5:nx-0.5;
Y = (-ny+0.5:ny-0.5)';
Rpx = sqrt(ones(2*ny,1)*(X.*X)+(Y.*Y)*ones(1,2*nx));

Image = interp1(rhoF,F,pxSize*floor(Rpx+0.5)); % +0.5 car le pixel n°1 de F correspond à une distance de pixel/2









