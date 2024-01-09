function pos = cylinder(dim,a,Dz)
%a:diameter of the mesh elements
Nr = floor(dim(1)/a);
Nz = floor(dim(2)/a);

pos0 = zeros(Nr*Nr*Nz,3);
ii = 0;
for ix = 0:Nr-1
    for iy = 0:Nr-1
        for iz = 0:Nz-1
            if (Nr/2-ix)^2+(Nr/2-iy)^2 < (Nr/2)^2
                ii = ii+1;
                pos0(ii,1) = ix;
                pos0(ii,2) = iy;
                pos0(ii,3) = iz;
            end
        end
    end
end
pos0(1:ii,1) = pos0(1:ii,1)-mean(pos0(1:ii,1));
pos0(1:ii,2) = pos0(1:ii,2)-mean(pos0(1:ii,2));
if nargin==3
    pos0(1:ii,3) = pos0(1:ii,3)-mean(pos0(1:ii,3))+Dz/a;
else
    pos0(1:ii,3) = pos0(1:ii,3)+1/2;
end
pos = pos0(1:ii,:)*a;