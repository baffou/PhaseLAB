function pos = spher(R,a,Dz)
%a: size of the mesh elements
%R: radius of the sphere
ii = 0;
N = floor(R/a);
for ix = -N:N
for iy = -N:N
for iz = -N:N
    if ix*ix+iy*iy+iz*iz <= R*R/(a*a)
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