function obj = removeMoment(obj0,type,n)
arguments
    obj0 ImageMethods
    type (:,1) char
    n = []
end

if nargout
    obj=copy(obj0);
else
    obj=obj0;
end
% possible inputs:
% 'coma', 'x^2+y^2', 'r^2'

Nx=obj0(1).Nx;
Ny=obj0(1).Ny;

[x, y] = meshgrid(1:Nx,1:Ny);
x = x - mean(x(:));
y = y - mean(y(:));

if strcmpi(type,'x^2+y^2') || strcmpi(type,'r^2') || strcmpi(type,'coma')
    U = x.^2+y.^2;
elseif strcmpi(type,'spin')
    U=imag(xx.^4 + 1i*yy.^4);
elseif strcmpi(type,'x^2+1i*y^2') || strcmpi(type,'x^2+i*y^2')
    U = x^2+1i*y^2;
elseif strcmpi(type,'x^n+1i*y^n') || strcmpi(type,'x^n+i*y^n')
    U = x^n+1i*y^n;
end

norm=sum(conj(U(:)).*U(:));

m = sum(obj.OPD(:).*U(:))/sqrt(norm);
obj.OPD = obj0.OPD-real(m)*real(U)-imag(m)*imag(U);



