function P = LegendrePoly(x,n)
% -------------------------------------------------------------------------
% Copyright 2020 Guillaume Baffou
% CNRS, Marseille, France
% guillaume.baffou@fresnel.fr
%
% License Agreement: To acknowledge the use of the code please cite the 
%                    following papers:
%
% -------------------------------------------------------------------------
% Function to compute Legendre polynomials:
%
% f = LegendrePoly(x,n)
% where
%   x = spatial coordinate
%   n = the order of Legendre polynomial

P = zeros(size(x));                     % Initilization

for k=0:n
    P=P+nchoosek(n,k)*nchoosek(n+k,k)*((x-1)/2).^k;
end



