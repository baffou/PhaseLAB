% Remove the Zernike polynomial image component (n,m) from the image.
% Useful to remove, e.g., an image tilt.

function Imout = SineRemoval(Im,n)

[Ny, Nx]=size(Im);

[X,Y]=meshgrid(1:Nx,1:Ny);
%X=X-mean(X(:));
%Y=Y-mean(Y(:));

Sxn=sin(n*2*pi*X/(2*Nx));
Syn=sin(n*2*pi*Y/(2*Ny));
Sxn=Sxn-mean(Syn(:));
Syn=Syn-mean(Syn(:));

Sxn0=Sxn/sqrt(sum(Sxn(:).*Sxn(:)));
Syn0=Syn/sqrt(sum(Syn(:).*Syn(:)));

mx=sum(sum(Im.*Sxn0));
my=sum(sum(Im.*Syn0));

Imout = Im-mx*Sxn0-my*Syn0;

