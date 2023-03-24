function [pos,chi] = shell2(a,R1,R2,eps1,eps2,eps_env,Dz)
if nargin==5
	Dz = 0;
end
%a:size of the mesh elements
%R1 radius of the core
%R2 radius of the shell
ii = 0;
N = floor(R2/a);
for ix = -N:N
for iy = -N:N
for iz = -N:N
    if ix*ix+iy*iy+iz*iz <= R1*R1/(a*a)
        ii = ii+1;
        pos(ii,1) = ix;
        pos(ii,2) = iy;
        pos(ii,3) = iz+Dz/a;
        chi(ii) = (eps1-eps_env)*a*a*a;
    elseif ix*ix+iy*iy+iz*iz <= R2*R2/(a*a)
        ii = ii+1;
        pos(ii,1) = ix;
        pos(ii,2) = iy;
        pos(ii,3) = iz+Dz/a;
        chi(ii) = (eps2-eps_env)*a*a*a;
    end
end
end
end
pos = pos*a;