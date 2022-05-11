function CG=CGgeneration(MI,IL)


%% Parameters

wl = IL.lambda;  % actual wavelength sent to the grating [m]
eD = MI.CGcam.CG.lambda0;      % wl corresponding to the etching depth of the checkerboard [m].
camPxSize = MI.CGcam.Camera.pxSize;   % camera chip pixel size [m]
zeta = MI.CGcam.zeta;         % zeta factor: Lambda/(2*camPxSize)
Npx = MI.CGcam.Camera.Ny;        % Desired final image size [px], must be square
zoom0 = MI.CGcam.zoom;        % Relay lens zoom
beta = MI.CGcam.CGangle;% tilt of the cross-grating [rad]. Possible values to maintain periodicity: 0 or acos(3/5)
%% Definition of some parameters
nCell = 10;     % Initial overdimensioned size[px] of the grating unit cell: 6*nCellx6*nCell
Gamma = MI.CGcam.CG.Gamma;       % size [m] of the unit cell of the grating

%% construction of the interferograms (Itf & Ref) according to Fig 2.

% (Fig 2a) Build the unit cell :
grexel = QLSIunitCell(nCell,pi*wl/eD,Gamma);
GratingBig=grexel.tile(6*nCell*Npx/(sqrt(2)*zeta));
GratingBig=GratingBig.rotation(beta*180/pi);
GratingBig=GratingBig.crop(3*nCell*Npx/zeta,3*nCell*Npx/zeta);
CG=GratingBig.redimension(camPxSize/zoom0,zeta/(3*nCell));


