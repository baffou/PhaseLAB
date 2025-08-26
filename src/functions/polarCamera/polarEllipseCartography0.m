function polarEllipseCartography0(pIm,N,opt)

arguments
    pIm (1,1) ImagePolar
    N  (1,2) double % [Ny, Nx] number of ellipses along the y annd x directions
    opt.Size (1,1) double = 0.9 % Scaling factor of the ellipses. 1 is 1 pixel
    opt.color = [0 1 1]
    opt.ABmin = []
    opt.axis = []
    opt.LineWidth = 1.5
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

if isempty(axis)
    ax = axes;
else
    ax = opt.axis;
end
hold on
for iy = 1:Ny
    for ix = 1:Nx
        %theta0 = pIm.theta0(posListY(iy),posListX(ix));
        theta0 = IMe.thetaEllipse(iy,ix);
        A = Aim(iy,ix);
        B = Bim(iy,ix);
        he = drawellipse(ax, ...
            'Center',[posListX(ix),posListY(iy)], ...
            'SemiAxes',[A-ABmin,B-ABmin]/(ABmax-ABmin)*Np/2*opt.Size, ...
            'RotationAngle',theta0*180/pi, ...
            'Color',opt.color, ...
            'FaceAlpha',0.2, ...
            'LineWidth',opt.LineWidth);

        he.InteractionsAllowed = 'none';
    end
end

xlim(ax,[0 pIm.Nx])
ylim(ax,[0 pIm.Ny])
set(ax,'DataAspectRatio',[1 1 1])
