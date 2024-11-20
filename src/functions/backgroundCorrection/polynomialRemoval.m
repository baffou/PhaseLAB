% Remove the Zernike polynomial image component (n,m) from the image.
% Useful to remove, e.g., an image tilt.

function [Imout, ms, mnorm] = polynomialRemoval(Im,method,n,m,opt)
arguments
    Im
    method (1,:) char {mustBeMember(method,{'Chebyshev','Chebyshev2','Hermite','Legendre'})} = 'Hermite'
    n = 1   % order of the polynomial along x
    m = 1   % order of the polynomial alongy
    opt.mask logical = logical.empty()
    opt.ms    = []  % moment
    opt.mnorm = []  % norm coef
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
    Hy=hermite(Y,m);
elseif strcmp(method,'Chebyshev')
    Hx=chebyshev(X,n,kind=1);
    Hy=chebyshev(Y,m,kind=1);
elseif strcmp(method,'Chebyshev2')
    Hx=chebyshev(X,n,kind=2);
    Hy=chebyshev(Y,m,kind=2);
elseif strcmp(method,'Legendre')
    Hx=legendre(X,n);
    Hy=legendre(Y,m);
end

if isempty(opt.ms)
    % un-normalized masked basis functions
    Hm=Hx.*Hy.*opt.mask;
    
    Hm(opt.mask==1)=Hm(opt.mask==1)-mean(Hm(opt.mask==1));
    
    % make sure they are proper, normalized basis functions
    Hm0=Hm;
    
    Hm0(opt.mask==1)=(Hm(opt.mask==1)-mean(Hm(opt.mask==1)));%.*opt.mask;
    
    
    if n~=0 || m~=0 % normalization unless for a flat profile
        mnorm=sqrt(sum(Hm0(:).*Hm0(:)));
    else
        mnorm=1;
    end
    
    Hm0n=Hm0/mnorm;
    
    % moments of the image on these basis functions
    I0=mean(Im(opt.mask==1));

    ms=sum(sum((Im-I0).*Hm0n));

else
    ms = opt.ms;
    mnorm = opt.mnorm;
end

Imout = Im-ms*Hx.*Hy/mnorm;

Imout=Imout-mean(Imout(:));
%fprintf('n=%d, m=%d\n',n,m)
