% Remove the Zernike polynomial image component (n,m) from the image.
% Useful to remove, e.g., an image tilt.

function [pout,mask,Zimage] = ZernikeRemoval(Im,n,m,r0,x0,y0)

N = min(size(Im));
if nargin==3
    r0 = N/2-1;
    x0 = N/2;
    y0 = N/2;
elseif nargin==4
    x0 = N/2;
    y0 = N/2;
elseif nargin~=6
    error('not he proper number of inputs')
end

r0 = round(r0);

if mod(n,2)~=mod(m,2)
    error('wrong parity of m')
end


Z = ZernikeMoment(Im,n,m,r0,x0,y0);

[Ny, Nx] = size(Im);
y = 1:Ny; x = 1:Nx;
[X,Y] = meshgrid(x,y);
R = sqrt((2.*X-2*x0-1).^2+(2.*Y-2*y0-1).^2)/(2*(r0+1));
Theta = atan2((2*y0-1-2.*Y+2),(2.*X-2*x0+1-2));
Rad = ZernikeRadialpoly(R,n,m);    % get the radial polynomial

% figure
% subplot(1,3,1)
% imagesc(A*(cosd(Phi)*ZernikeX+sind(Phi)*ZernikeY))
% colorbar
% subplot(1,3,2)
% imagesc(p)
% colorbar
% subplot(1,3,3)

Zimage = 0.5*Rad.*(Z'*exp(-1i*m*Theta)+Z*exp(+1i*m*Theta));
pout = Im-Zimage;

mask = (R<=1);










