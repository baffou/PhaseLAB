function CG=CGgeneration(MI,IL,beta)
arguments
    MI Microscope
    IL Illumination
    beta = [] % rotation angle of the grating
end


%% Parameters

wl = IL.lambda;  % actual wavelength sent to the grating [m]
eD = MI.CGcam.CG.lambda0;      % wl corresponding to the etching depth of the checkerboard [m].
p_p = MI.CGcam.dxSize;   % effective camera chip pixel size p'=p*Z [m]
zeta = MI.CGcam.zeta;         % zeta factor: Lambda/(2*camPxSize)
Npx = MI.CGcam.Camera.Ny;        % Desired final image size [px], must be square
if isempty(beta)
    beta = MI.CGcam.CG.angle;% tilt of the cross-grating [rad]. Possible values to maintain periodicity: 0 or acos(3/5)
end
%% Definition of some parameters
nCell = 10;     % Initial overdimensioned size[px] of the grating unit cell: 6*nCellx6*nCell
Gamma = MI.CGcam.CG.Gamma;       % size [m] of the unit cell of the grating

%% construction of the interferograms (Itf & Ref) according to Fig 2.

% (Fig 2a) Build the unit cell :
grexel = QLSIunitCell(nCell,pi*wl/eD,Gamma);
GratingBig=grexel.tile(ceil(6*nCell*Npx/(sqrt(2)*zeta)));
GratingBig=GratingBig.rotation(beta);
GratingBig=GratingBig.crop(round(3*nCell*Npx/zeta),round(3*nCell*Npx/zeta));
CG=GratingBig.redimension(p_p,zeta/(3*nCell));


