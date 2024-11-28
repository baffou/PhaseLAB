function pos = ellipsoid(R,a,Dz)
%a: size of the mesh elements
%R: 3-vector representing the radii of the spheroid along x, y, and z

R1 = R(1)/a;
R2 = R(2)/a;
R3 = R(3)/a;

ii = 0;
N1 = ceil(R1)+1;
N2 = ceil(R2)+2;
N3 = ceil(R3)+3;
for ix = -N1:N1
for iy = -N2:N2
for iz = -N3:N3
    if ix*ix/(R1*R1)+iy*iy/(R2*R2)+iz*iz/(R3*R3)<=1
        ii = ii+1;
        pos(ii,1) = ix;
        pos(ii,2) = iy;
        pos(ii,3) = iz;
    end
end
end
end

if nargin==2
    minz = min(pos(:,3));
    pos(:,3) = pos(:,3)-minz+0.5;
else
    pos(:,3) = pos(:,3)+Dz;
end
pos = pos*a;