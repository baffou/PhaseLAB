function polarEllipseCartography0(pIm,N,opt)

arguments
    pIm (1,1) ImagePolar
    N  (1,2) double % [Ny, Nx] number of ellipses along the y annd x directions
    opt.Size (1,1) double = 1 % Scaling factor of the ellipses
    opt.color = [0 1 1]
    opt.ABmin = []
end

IMe = ImageEM(pIm.IM);

Ny = N(1);
Nx = N(2);

Npy = pIm.Ny/Ny;
Npx = pIm.Nx/Nx;

Np = min([Npy,Npx]);

posListY = linspace(Npy/2,pIm.Ny-Npy/2,Ny);
posListX = linspace(Npx/2,pIm.Nx-Npx/2,Nx);

posListY = round(posListY);
posListX = round(posListX);


%eSize = min([pIm.Ny/Ny,pIm.Nx/Nx])*Size/2;

Aim = imresize(IMe.A,[Ny,Nx]);
Bim = imresize(IMe.B,[Ny,Nx]);

Amax = max(Aim(:));
Bmax = max(Bim(:));
Amin = min(Aim(:));
Bmin = min(Bim(:));

ABmax = max([Amax,Bmax]);

if isempty(opt.ABmin)
    ABmin = min([Amin,Bmin]);
else
    ABmin = opt.ABmin;
end

figure
hold on
for iy = 1:Ny
    for ix = 1:Nx
        %theta0 = pIm.theta0(posListY(iy),posListX(ix));
        theta0 = IMe.theta(iy,ix);
        A = Aim(iy,ix);
        B = Bim(iy,ix);
        he = drawellipse(...
            'Center',[posListX(ix),posListY(iy)], ...
            'SemiAxes',[A-ABmin,B-ABmin]/(ABmax-ABmin)*Np/2*opt.Size, ...
            'RotationAngle',theta0, ...
            'Color',opt.color, ...
            'FaceAlpha',0.2, ...
            'LineWidth',2);

        he.InteractionsAllowed = 'none';
    end
end

xlim([0 pIm.Nx])
ylim([0 pIm.Ny])
set(gca,'DataAspectRatio',[1 1 1])

