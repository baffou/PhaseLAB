% Remove the Zernike polynomial image component (n,m) from the image.
% Useful to remove, e.g., an image tilt.

function Imout = polynomialRemoval(Im,method,n,opt)
arguments
    Im
    method (1,:) char {mustBeMember(method,{'Chebyshev','Chebyshev2','Hermite','Legendre'})} = 'Hermite'
    n = 2   % order of the polynomial
    opt.mask logical = logical.empty()
end
% Im=IM(1).OPD;
% method="Legendre";
% n=2;
% opt.mask = logical.empty();


if isempty(opt.mask)
    opt.mask = ones(size(Im))==1;
end
[Ny, Nx]=size(Im);

[X,Y]=meshgrid(linspace(-1,1,Nx),linspace(-1,1,Ny));

if strcmp(method,'Hermite')
    Hx=hermite(X,n);
    Hy=hermite(Y,n);
elseif strcmp(method,'Chebyshev')
    Hx=chebyshev(X,n,kind=1);
    Hy=chebyshev(Y,n,kind=1);
elseif strcmp(method,'Chebyshev2')
    Hx=chebyshev(X,n,kind=2);
    Hy=chebyshev(Y,n,kind=2);
elseif strcmp(method,'Legendre')
    Hx=legendre(X,n);
    Hy=legendre(Y,n);
end

% un-normalized masked basis functions
Hxm=Hx.*opt.mask;
Hym=Hy.*opt.mask;

% make sure they are proper, normalized basis functions
Hxm0=Hxm;
Hym0=Hym;

Hxm0(opt.mask==1)=Hxm(opt.mask==1)-mean(Hxm(opt.mask==1));
Hym0(opt.mask==1)=Hym(opt.mask==1)-mean(Hym(opt.mask==1));
xmnorm=sqrt(sum(Hxm0(:).*Hxm0(:)));
ymnorm=sqrt(sum(Hym0(:).*Hym0(:)));
Hxm0n=Hxm0/xmnorm;
Hym0n=Hym0/ymnorm;

% moments of the image on these basis functions
msx=sum(sum(Im.*Hxm0n));
msy=sum(sum(Im.*Hym0n));

% unmasked basis functions
Hx0=Hx-mean(Hx(:));
Hy0=Hy-mean(Hy(:));

Imout = Im-msx*Hx0/xmnorm-msy*Hy0/ymnorm;

if n==3
    pause(1)
end
