function [Itf, Grating] = CGMinSilico(Image,opt)
% Function that creates a simulated interferogram from a given T/OPD set of
% images, including the image noise
% For this purpose, it uses all the data of the Microscope object contained
% in the ImageMethods object.
% CGMinSilico(Image, 'Nimages'=Nim, 'Shotnoise'='on')
arguments
    Image ImageMethods
    opt.Nimages (1,1) {mustBeInteger,mustBePositive} = 1
    opt.ShotNoise (1,:) char {mustBeMember(opt.ShotNoise,{'on','off'})} = 'on'
    opt.Grating char ='QLSI'
    opt.NAill double = 0
    opt.setI0 (1,:) char {mustBeMember(opt.setI0,{'max','mean'})} = 'max'
    opt.cut (1,1) double = 0
end

if strcmpi(opt.ShotNoise,'on')
    noiseFunction=@poissrnd;
else
    noiseFunction=@identity;
end

No=numel(Image);
Itf=repmat(Interfero(),No,1);
ItfRef=repmat(Interfero(),No,1);
for io=1:No
    
    
    T=Image(io).T;
    OPD=Image(io).OPD;
    Pha=Image(io).Ph;
    
    %% Parameters
    MI=Image(io).Microscope;
    Nim=double(opt.Nimages);
    
    wl = Image(io).lambda;  % actual wavelength sent to the grating [m]
    eD = MI.CGcam.CG.lambda0;      % wl corresponding to the etching depth of the checkerboard [m].
    camPxSize = MI.CGcam.Camera.pxSize;   % camera chip pixel size [m]
    zeta = MI.CGcam.zeta;         % zeta factor: Lambda/(2*camPxSize)
    w = MI.CGcam.Camera.fullWellCapacity;        % full well capacity of the camera
    [Ny,Nx] = size(OPD);        % Desired final image size [px], must be square
    zoom0 = MI.CGcam.zoom;        % Relay lens zoom
    beta = acos(3/5);% tilt of the cross-grating [rad]. Possible values to maintain periodicity: 0 or acos(3/5)
    IL=Image.Illumination;
    %% Definition of some parameters
    nCell = 20;     % Initial overdimensioned size[px] of the grating unit cell: 6*nCellx6*nCell
    Lambda = MI.CGcam.CG.Gamma;       % size [m] of the unit cell of the grating
    
    %% construction of the interferograms (Itf & Ref) according to Fig 2.
    
    % (Fig 2a) Build the unit cell :
    if strcmpi(opt.Grating,'QLSI')
        grexel = QLSIunitCell(nCell,pi*wl/eD,Lambda);
    elseif strcmpi(opt.Grating,'QLSI0')
        grexel = QLSIunitCell0(nCell,pi*wl/eD,Lambda);
    end
    % (Fig 2b) 5x5-tile and rotate by acos(4/5) the unit cell to form the superunit cell
    % image, enabling periodicity when further tiling :
        superUnit = grexel.TileRot5(beta);
    % (Fig 2c) Resizing of the superunit cell by imresize to match the pixel size of the camera :
        superUnitPixelized = superUnit.redimension(camPxSize/zoom0,zeta/(3*nCell));

    % (Fig2d) generation of the final E field by tiling until reaching the desired Npx
    % px number of the image :
        Grating = superUnitPixelized.tile(Nx,Ny);
    
    Emodel = Grating;
    Emodel.im = sqrt(T).*exp(1i*Pha);

    EmodelRef = Grating;
    EmodelRef.im = ones(Ny,Nx);
    
    %Emodelb = Emodel.propagation(wl,-d0);% Backpropagation of the light from the camera chip
    %Emodelb = Emodel.propagation2(MI,IL,dir='backward');% Backpropagation of the light from the camera chip
    %Egrating = Grating.*Emodelb;
    %EmodelRefb = EmodelRef.propagation(wl,-d0);
    %EmodelRefb = EmodelRef.propagation2(MI,IL,dir='backward');
    %ErefGrating = Grating.*EmodelRefb;
    
    % (Fig 2e,g) Propagate the light after the unit cell:
    %E    = Egrating.propagation(wl,d0);
    %Eref = ErefGrating.propagation(wl,d0);
    %E    = Egrating.propagation2(MI,IL,dir='forward');
    %Eref = ErefGrating.propagation2(MI,IL,dir='forward');

    E20    =    Emodel.BackForPropagation(Grating,MI,IL);% Backpropagation of the light from the camera chip
    E2Ref0 = EmodelRef.BackForPropagation(Grating,MI,IL);% Backpropagation of the light from the camera chip

    % (Fig 2h,i) compute the intensity images:
    [E2,fac] = E20.setI0(w*Nim,mode=opt.setI0); % set the max counts of the interferogram
    E2Ref = E2Ref0.timesC(fac);% Apply the same correction factor to the reference interferogram
    % hfig=figure;
    % subplot(1,2,1)
    % E.figure(hfig)
    % title(sprintf('Real part of E-field at the camera plane\n Interfero'))
    % subplot(1,2,2)
    % Eref.figure(hfig)
    % title(sprintf('Real part of E-field at the camera plane\n Reference'))
    % drawnow
    
    cut = opt.cut;% =1 or 2. to make artificial crosses in the Fourier space and better
            % match what is observed experimentally. Otherwise, set to 0.
            % Note it reduces the image size from Npx to Npx-cut.
    
    % Add the shoit noise on the interferograms:  
    Itf(io)    = Interfero(noiseFunction(   E2.im(1+cut:end-cut,1+cut:end-cut)),MI);
    ItfRef(io) = Interfero(noiseFunction(E2Ref.im(1+cut:end-cut,1+cut:end-cut)),MI);
    Itf(io).Reference(ItfRef(io));
    
    
    % plot of the interferogram and its Fourier transform:
    % figure
    % subplot(1,2,1)
    % imagebw(Itf.Itf)
    % title('interferogram')
    % subplot(1,2,2)
    % imagetf(Itf.Ref.Itf)
    % title('Fourier transform of the interferogram')
    % 

end