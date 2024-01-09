function m_xy = LegendreMoment(A,n,m)

% -------------------------------------------------------------------------
% Copyright C 2020 Guillaume Baffou
% CNRS, Marseille France
% guillaume.baffou@fresnel.fr
%
% License Agreement: To acknowledge the use of the code please cite the 
%                    following papers:
%
% -------------------------------------------------------------------------
% Function to find the Legendre moments for an N x N image
%
% M = LegendreMoment(p,n,m)
% where
%   A = input image N x N matrix (N should be an even number)
%   n = The order of Legendre moment along x (scalar)
%   m = The order of Legendre moment along y (scalar)
% and
%   M = The Legendre moment 


[Ny,Nx] = size(A);

%x = (-Nx/2+0.5 : 1 : Nx/2-0.5)/(Nx/2-0.5);
%y = (-Ny/2+0.5 : 1 : Ny/2-0.5)/(Ny/2-0.5);
x = linspace(-1, 1, Nx);
y = linspace(-1, 1, Ny);
[X,Y] = meshgrid(x, y);


Hx=legendre(X,n);
Hy=legendre(Y,m);

Hx=Hx-mean(mean(Hx));
Hy=Hy-mean(mean(Hy));
xmnorm=sqrt(sum(Hx(:).*Hx(:)));
ymnorm=sqrt(sum(Hy(:).*Hy(:)));
Hxn=Hx/xmnorm;
Hyn=Hy/ymnorm;

% moments of the image on these basis functions
mx=sum(sum(A.*Hxn));
my=sum(sum(A.*Hyn));

m_xy=[mx, my];