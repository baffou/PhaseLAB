function pos = rod(dim,a,Dz)
% dim:[total length, radius of the caps]
L = dim(1);
R = dim(2);

if L<2*R
    error('Wrong dimensions of the rod. First specify the length and then the radius.')
end

ii = 0;
N0 = floor(R/a);
N = floor(L/2/a);
sh = (L-2*R)/2;
for ix = -N:N
for iy = -N0:N0
for iz = -N0:N0
    if (ix-sh/a)*(ix-sh/a)+iy*iy+iz*iz<=R*R/(a*a)...
     ||(ix+sh/a)*(ix+sh/a)+iy*iy+iz*iz<=R*R/(a*a)...
     ||( iy*iy+iz*iz<=R*R/(a*a) && ix<=sh/a && ix>=-sh/a )
        ii = ii+1;
        pos(ii,1) = ix;
        pos(ii,2) = iy;
        pos(ii,3) = iz;
    end
end
end
end

pos(:,1) = pos(:,1)-mean(pos(:,1));
pos(:,2) = pos(:,2)-mean(pos(:,2));

if nargin==3
    pos(:,3) = pos(:,3)-mean(pos(:,3))+Dz/a;
else
    pos(:,3) = pos(:,3)-min(pos(:,3))+1/2;
end
pos = pos*a;









