function mask = circularMask(Nx, Ny, cx, cy, R)
% returns a matrix with 1 within a circluar area
[XX, YY] = meshgrid(0:Nx-1,0:Ny-1);

R2=(XX-cx).*(XX-cx)+(YY-cy).*(YY-cy);

mask = R2<R^2;

