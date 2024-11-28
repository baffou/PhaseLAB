%% FUNCTION THAT COMPUTES THE GREEN'S FUNCTION FOR A 2-LAYER SYSTEM.
%
% Green=greenT(universe,image[,z0])
%
% universe: Array of 2 Layer objects.
% image:    Sid4image object (to know pxSize, nx and ny).
% z0: optional. If not specified, the function returns a 3D array according
% to the meshing of universe. If a z0 scalar is specified, the function
% returns a 2D matrix corresponding at the height z0.

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 1, 2018

function Green=greenT_2layers(universe,nx,ny,MI,z0)

if length(universe)==3
    warning('Something''s wrong, you are trying to compute a 2-layer Green''s function while your system has 3 layers')
end

k2 = universe(2).kappa;
k1 = universe(1).kappa;

kappa = (k1+k2)/2;

pxSize = MI.pxSize;


Rbig.x = ( (1:2*nx)-nx-0.5 )*pxSize ;
Rbig.y = ( (1:2*ny)-ny-0.5 )*pxSize ;
xxBig = ones(2*ny,1) * Rbig.x ;   
yyBig = Rbig.y' * ones(1,2*nx) ;

if nargin==3
    z = [universe(1).mesh.z(universe(1).mesh.npx:-1:2) universe(2).mesh.z];
    nz = length(z);
    Green = zeros(2*ny,2*nx,nz);
    for ll = 1:nz-1
        zz = z(ll);
        rhoBig = sqrt(xxBig.*xxBig+yyBig.*yyBig + zz*zz);

        Green(:,:,ll) = 1./rhoBig;

    end %for ll
else
    Green=1./sqrt(xxBig.*xxBig+yyBig.*yyBig+z0*z0);
end

Green = Green/(4*pi*kappa);
