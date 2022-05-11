function Mt=rotation(i,j,M,theta)

M1=[M M(:,1);M(1,:) M(1,1)]; % make the unit matrix a bit bigger (one row and one line) to avoid modulo problems
N=size(M,1);
N1=size(M1,1);

it= i*cos(theta)-j*sin(theta);
jt= i*sin(theta)+j*cos(theta);

%    a=interp2(1:N,1:N,M,2, 1)


Mt=interp2(1:N1,1:N1,M1,mod(it-1,N)+1, mod(jt-1,N)+1);





