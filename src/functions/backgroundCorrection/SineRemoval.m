% Remove the Zernike polynomial image component (n,m) from the image.
% Useful to remove, e.g., an image tilt.

function Imout = SineRemoval(Im,n,mask)
if nargin==2
    mask = ones(size(Im));
end
[Ny, Nx]=size(Im);

[X,Y]=meshgrid(1:Nx,1:Ny);
%X=X-mean(X(:));
%Y=Y-mean(Y(:));

% Sines
Sxn=sin(n*2*pi*X/(2*Nx));
Syn=sin(n*2*pi*Y/(2*Ny));
Sxn=Sxn-mean(Sxn(:));
Syn=Syn-mean(Syn(:));
Sxn0=Sxn/sqrt(sum(Sxn(:).*Sxn(:)));
Syn0=Syn/sqrt(sum(Syn(:).*Syn(:)));

msx=sum(sum(Im.*Sxn0.*mask))*sum(mask(:))/(Nx*Ny);
msy=sum(sum(Im.*Syn0.*mask))*sum(mask(:))/(Nx*Ny);


% Cosines
Cxn=cos(n*2*pi*X/(2*Nx));
Cyn=cos(n*2*pi*Y/(2*Ny));
Cxn=Cxn-mean(Cxn(:));
Cyn=Cyn-mean(Cyn(:));
Cxn0=Cxn/sqrt(sum(Cxn(:).*Cxn(:)));
Cyn0=Cyn/sqrt(sum(Cyn(:).*Cyn(:)));

mcx=sum(sum(Im.*Cxn0.*mask))*(Nx*Ny)/sum(mask(:));
mcy=sum(sum(Im.*Cyn0.*mask))*(Nx*Ny)/sum(mask(:));

Imout = Im-msx*Sxn0-msy*Syn0-mcx*Cxn0-mcy*Cyn0;

