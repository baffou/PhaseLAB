function pos = cuboid(dim,a,Dz)
%a:diameter of the mesh elements
Nx = floor(dim(1)/a);
Ny = floor(dim(2)/a);
Nz = floor(dim(3)/a);

pos = zeros(Nx*Ny*Nz,3);
ii = 0;
for ix = 0:Nx-1
for iy = 0:Ny-1
for iz = 0:Nz-1
    ii = ii+1;
    pos(ii,1) = ix-(Nx-1)/2;
    pos(ii,2) = iy-(Ny-1)/2;
    pos(ii,3) = iz;
end
end
end
pos(:,1) = pos(:,1)-mean(pos(:,1));
pos(:,2) = pos(:,2)-mean(pos(:,2));

if nargin==3
    pos(:,3) = pos(:,3)-mean(pos(:,3))+Dz/a;
else
    pos(:,3) = pos(:,3)+1/2;
end

pos = pos*a;


