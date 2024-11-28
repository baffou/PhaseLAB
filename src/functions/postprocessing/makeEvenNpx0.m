function image = makeEvenNpx0(image0)

[Ny, Nx] = size(image0);
image = image0(1:floor(Ny/2)*2, 1:floor(Nx/2)*2);