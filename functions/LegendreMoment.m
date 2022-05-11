function [LMoment, LImage] = LegendreMoment(p,n,m)

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
%   p = input image N x N matrix (N should be an even number)
%   n = The order of Legendre moment along x (scalar)
%   m = The order of Legendre moment along y (scalar)
% and
%   M = The Legendre moment 


[Ny,Nx] = size(p);

x = (-Nx/2+0.5:1:Nx/2-0.5)/(Nx/2-0.5); y = (-Ny/2+0.5:1:Ny/2-0.5)/(Ny/2-0.5);
[X,Y] = meshgrid(x,y);

LImage=LegendrePoly(X,n).*LegendrePoly(Y,m);    % get the radial polynomial



LMoment=(2*n+1)*(2*m+1)/4*sum(sum(LImage.*p));
LMoment=LMoment/(Nx*Ny);



%Z = sum(Product(:));        % calculate the moments

%epsm=2-mod(m,2);
%cnt = nnz(R)+1;             % count the number of pixels inside the unit circle
%Z = (n+1)*Z/cnt/epsm;            % normalize the amplitude of moments
%A = abs(Z);                 % calculate the amplitude of the moment
%Phi = angle(Z)*180/pi;      % calculate the phase of the mement (in degrees)


