function pos=cube(L,a,Dz)
N=floor(L/a);
pos=zeros(N*N*N,3);
ii=0;
for ix=1:N
for iy=1:N
for iz=1:N
    ii=ii+1;
    pos(ii,1)=ix;
    pos(ii,2)=iy;
    pos(ii,3)=iz;
end
end
end
pos(:,1)=pos(:,1)-mean(pos(:,1));
pos(:,2)=pos(:,2)-mean(pos(:,2));

if nargin==3
    pos(:,3)=pos(:,3)-mean(pos(:,3))+Dz/a;
else
    pos(:,3)=pos(:,3)+1/2;
end
pos=pos*a;